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
  # Add ethertype based on the presence of ':' in remote_ip_prefix
  processed_ingress_rules = [
    for r in var.ingress_rules : merge(
      r,
      {
        direction = "ingress",
        ethertype = can(regex(":", lookup(r, "remote_ip_prefix", ""))) ? "IPv6" : "IPv4"
      }
    )
  ]

  processed_egress_rules = [
    for r in var.egress_rules : merge(
      r,
      {
        direction = "egress",
        ethertype = can(regex(":", lookup(r, "remote_ip_prefix", ""))) ? "IPv6" : "IPv4"
      }
    )
  ]

  # Combine all rules
  rules = concat(local.processed_ingress_rules, local.processed_egress_rules)
}

resource "openstack_networking_secgroup_rule_v2" "rules" {
  for_each = var.create ? { for idx, rule in local.rules : idx => rule } : {}

  region            = var.region == null ? null : var.region
  security_group_id = local.this_sg_id
  direction         = each.value.direction
  ethertype         = each.value.ethertype
  protocol          = lookup(each.value, "protocol", null)
  port_range_min    = lookup(each.value, "port", lookup(each.value, "port_range_min", null))
  port_range_max    = lookup(each.value, "port", lookup(each.value, "port_range_max", null))
  description       = each.value.description

  # Set remote_ip_prefix only if it is provided and remote_group_id is null
  remote_ip_prefix = lookup(each.value, "remote_ip_prefix", null) != null && lookup(each.value, "remote_group_id", null) == null ? each.value.remote_ip_prefix : null

  # If "remote_group_id" is set to "@self", use the current security group ID (local.this_sg_id).
  # If "remote_group_id" is not null and "remote_ip_prefix" is null, use the value of "remote_group_id".
  # Otherwise, set the value to null.
  remote_group_id = lookup(each.value, "remote_group_id", null) == "@self"
    ? local.this_sg_id
    : (lookup(each.value, "remote_group_id", null) != null && lookup(each.value, "remote_ip_prefix", null) == null
      ? lookup(each.value, "remote_group_id", null)
      : null)
}
