resource "random_id" "this" {
  keepers = {
    name_prefix = var.name_prefix
  }
  byte_length = 8
}

##################################
# Create Security Group
##################################
resource "openstack_networking_secgroup_v2" "this" {
  for_each = var.create && false == var.use_name_prefix ? { "id" = 1 } : {}

  name        = local.this_sg_name
  description = var.description

  tags                 = var.tags
  delete_default_rules = var.delete_default_rules
  stateful             = var.stateful

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  this_sg_id   = try(openstack_networking_secgroup_v2.this["id"].id, "")
  this_sg_name = var.use_name_prefix ? (var.name_prefix == "" ? "${random_id.this.hex}-${var.name}" : "${var.name_prefix}-${var.name}") : var.name
}

######################
# Security group rules
######################
locals {
  ingress_rules_ipv4 = [for r in var.ingress_rules_ipv4 : merge(r, { direction = "ingress", ethertype = "IPv4" })]
  ingress_rules_ipv6 = [for r in var.ingress_rules_ipv6 : merge(r, { direction = "ingress", ethertype = "IPv6" })]
  ingress_rules      = concat(local.ingress_rules_ipv4, local.ingress_rules_ipv6)

  ingress_rules_both_ipv6 = [for r in var.ingress_rules : merge(r, { direction = "ingress", ethertype = "IPv6" })]
  ingress_rules_both_ipv4 = [for r in var.ingress_rules : merge(r, { direction = "ingress", ethertype = "IPv4" })]
  ingress_rules_both      = concat(local.ingress_rules_both_ipv4, local.ingress_rules_both_ipv6)

  egress_rules_ipv4 = [for r in var.egress_rules_ipv4 : merge(r, { direction = "egress", ethertype = "IPv4" })]
  egress_rules_ipv6 = [for r in var.egress_rules_ipv6 : merge(r, { direction = "egress", ethertype = "IPv6" })]
  egress_rules      = concat(local.egress_rules_ipv4, local.egress_rules_ipv6)

  egress_rules_both_ipv6 = [for r in var.egress_rules : merge(r, { direction = "egress", ethertype = "IPv6" })]
  egress_rules_both_ipv4 = [for r in var.egress_rules : merge(r, { direction = "egress", ethertype = "IPv4" })]
  egress_rules_both      = concat(local.egress_rules_both_ipv4, local.egress_rules_both_ipv6)

  rules = concat(local.ingress_rules_both, local.egress_rules_both, local.ingress_rules, local.egress_rules)
}

resource "openstack_networking_secgroup_rule_v2" "rules" {
  for_each           = var.create ? { for idx, rule in local.rules : idx => rule } : {}

  region             = var.region
  security_group_id  = local.this_sg_id
  direction          = each.value.direction
  ethertype          = each.value.ethertype
  protocol           = lookup(each.value, "protocol", "")
  port_range_min     = lookup(each.value, "port", lookup(each.value, "port_range_min", null))
  port_range_max     = lookup(each.value, "port", lookup(each.value, "port_range_max", null))
  description        = each.value.description
  remote_ip_prefix   = lookup(each.value, "remote_ip_prefix", null) != null ? each.value.remote_ip_prefix : (each.value.ethertype == "IPv6" ? var.default_ipv6_remote_ip_prefix : var.default_ipv4_remote_ip_prefix)
  remote_group_id    = each.value.remote_group_id == "@self" ? local.this_sg_id : each.value.remote_group_id
}
