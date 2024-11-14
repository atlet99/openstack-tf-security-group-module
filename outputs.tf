output "security_group_id" {
  description = "The ID of the security group"
  value       = try(values(openstack_networking_secgroup_v2.this)[0].id, "")
}

output "security_group_name" {
  description = "The name of the security group"
  value       = try(values(openstack_networking_secgroup_v2.this)[0].name, "")
}
