# modules/networking

VPC 10.30.0.0/16 + 6 subnets sur 2 AZ + NAT single + 2 VPC endpoints.

## Inputs

- project_name (string, required)
- environment (string, required)
- vpc_cidr (string, default "10.30.0.0/16")
- azs (list(string), default ["eu-west-3a","eu-west-3b"])

## Outputs

- vpc_id, vpc_cidr
- public_subnet_ids (map)
- private_app_subnet_ids (map)
- private_db_subnet_ids (map)
- nat_gateway_public_ip
- vpc_endpoints_security_group_id

## Usage

```hcl
module "networking" {
  source       = "../../modules/networking"
  project_name = "nextcloud"
  environment  = "dev"
}
```
