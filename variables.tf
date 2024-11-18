#################
# Security group
#################
variable "create" {
  description = "Whether to create security group and all rules"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of security group"
  type        = string
}

variable "name_prefix" {
  description = "Name prefix of security group"
  type        = string
  default     = ""
}

variable "use_name_prefix" {
  description = "Whether to use name_prefix before name or not"
  type        = bool
  default     = false
}

variable "description" {
  type        = string
  description = "Description of security group"
  default     = "Managed by Terraform"
}

variable "tags" {
  description = "A set of string tags to assign to security group"
  type        = set(string)
  default     = []
}

variable "delete_default_rules" {
  type        = bool
  description = "Whether to delete default security group rules"
  default     = true
}

variable "stateful" {
  description = "Indicates if the security group is stateful or stateless"
  type        = bool
  default     = true
}

variable "region" {
  description = "Region where the security group is located"
  type        = string
  default     = ""
}

##########
# Ingress
##########
variable "ingress_rules" {
  description = <<EOT
List of ingress rules. Each rule can define:
- `protocol` (optional): Protocol to allow (e.g., "tcp", "udp", "icmp").
- `port` or `port_range_min`/`port_range_max` (optional): Single port or range.
- `remote_ip_prefix` (optional): CIDR for allowed source IPs (determines ethertype).
- `remote_group_id` (optional): Security group ID for allowed source.
- `description` (optional): Description of the rule.

Example:
[
  {
    protocol        = "tcp"
    port            = 22
    remote_ip_prefix = "0.0.0.0/0"
    description     = "Allow SSH"
  },
  {
    protocol        = "icmp"
    remote_ip_prefix = "::/0"
    description     = "Allow ICMP over IPv6"
  }
]
EOT
  type        = list(map(string))
  default     = []
}

#########
# Egress
#########
variable "egress_rules" {
  description = <<EOT
List of egress rules. Each rule can define:
- Same structure as `ingress_rules`.

Example:
[
  {
    protocol        = "tcp"
    port            = 22
    remote_ip_prefix = "0.0.0.0/0"
    description     = "Allow SSH"
  },
  {
    protocol        = "icmp"
    remote_ip_prefix = "::/0"
    description     = "Allow ICMP over IPv6"
  }
]
EOT
  type        = list(map(string))
  default     = []
}

