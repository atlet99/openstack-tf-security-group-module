# Terraform OpenStack Security Group Module

Terraform module which creates security groups on OpenStack.

## Features

- Supports creation of security groups with dynamic names and tags.
- Allows defining stateful or stateless security groups.
- Supports custom ingress and egress rules with detailed configurations.
- Automatically handles IPv4/IPv6 rules based on the provided IP prefixes.

## Requirements

- `Terraform >= 1.5.0`
- `Terraform OpenStack Provider ~> 3.0.0`
- `Terraform Random Provider >= 3.6.3`

## Usage

### Basic Example

```hcl
module "security_group" {
  source = "github.com/atlet99/openstack-tf-security-group-module?ref=v1.0.0"

  name               = "my-security-group"
  name_prefix        = "project"
  use_name_prefix    = true
  description        = "Security group for my project"
  tags               = ["tag1", "tag2"]
  delete_default_rules = true
  stateful           = true
  region             = "main"

  ingress_rules = [
    {
      protocol        = "tcp"
      port            = 22
      remote_ip_prefix = "0.0.0.0/0"
      description     = "Allow SSH access"
    },
    {
      protocol        = "icmp"
      remote_ip_prefix = "::/0"
      description     = "Allow ICMP over IPv6"
    }
  ]

  egress_rules = [
    {
      protocol        = "tcp"
      port            = 80
      remote_ip_prefix = "0.0.0.0/0"
      description     = "Allow HTTP traffic"
    },
    {
      protocol        = "tcp"
      port            = 443
      remote_ip_prefix = "0.0.0.0/0"
      description     = "Allow HTTPS traffic"
    }
  ]
}
```

## Outputs

After applying this module, you can retrieve the following outputs:
```hcl
output "security_group_id" {
  value = module.security_group.security_group_id
}

output "security_group_name" {
  value = module.security_group.security_group_name
}
```

## Inputs

### Security Group Configuration:

| Name                | Description                                           | Type        | Default                |
|---------------------|-------------------------------------------------------|-------------|------------------------|
| create              | Whether to creater the security group and its rules   | bool        | true                   |
| name                | Name of the security group                            | string      | N/A                    |
| name_prefix         | Prefix to prepend to the security group name          | string      | ""                     |
| use_name_prefix     | Whether to use the name prefix                        | bool        | false                  |
| description         | Description of the security group                     | string      | "Managed by Terraform" |
| tags                | Tags to assign to the security group                  | set(string) | []                     |
| delete_default_rule | Whether to delete default rules in the security group | bool        | false                  |
| stateful            | Whether the security group is stateful                | bool        | true                   |
| region              | OpenStack region                                      | string      | ""                     |

### Rule Configuration:

| Name         | Description                                    | Type      | Default |
|--------------|------------------------------------------------|-----------|---------|
| ingress_rule | List of ingress rules (see example for format) | list(map) | []      |
| egress_rule  | List of egress rules (see example for format)  | list(map) | []      |

### Outputs
| Name                | Description                            |
|---------------------|----------------------------------------|
| security_group_id   | The ID of the created security group   |
| security_group_name | The name of the created security group |

## Notes

* The module dynamically determines the ethertype (IPv4/IPv6) for rules based on IP prefix format.
* Format remote_group_id, you can use `@self` to reference the current security group.

## License

This is an open source project under the [MIT](https://github.com/atlet99/openstack-tf-security-group-module/blob/master/LICENSE) license.
