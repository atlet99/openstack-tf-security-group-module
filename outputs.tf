output "security_group_id" {
  description = "The ID of the security group"
  value       = try(openstack_networking_secgroup_v2.this["id"].id, "")
}

output "security_group_name" {
  description = "The name of the security group"
  value       = try(openstack_networking_secgroup_v2.this[0].name, "")
}
