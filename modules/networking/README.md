# Module `networking`

Module VPC pour le projet Nextcloud Kolab.

Créé par le **Rôle 2 — Network Engineer** lors du TP05.

## Contenu attendu

- VPC `10.30.0.0/16` (eu-west-3)
- 6 subnets : 2 publics / 2 privés app / 2 privés DB
- Internet Gateway + NAT Gateway (single-AZ)
- Route tables et associations
- 3 VPC Endpoints : S3 (Gateway), Secrets Manager et KMS (Interface)

## Interface

Voir `variables.tf` (inputs) et `outputs.tf` (outputs exposés aux autres modules).

Consultez [role-2-network.md](../../../cours/jour5/tp05-team-nextcloud/role-2-network.md) pour les étapes détaillées.

## Génération README automatique

Bonus : `terraform-docs markdown table --output-file README.md --output-mode inject .`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.vpc_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.private_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.secretsmanager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_security_group_ingress_rule.vpce_https_from_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azs"></a> [azs](#input\_azs) | Liste des Availability Zones. 2 AZ minimum pour Multi-AZ RDS. | `list(string)` | <pre>[<br/>  "eu-west-3a",<br/>  "eu-west-3b"<br/>]</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Nom de l environnement (dev, staging, prod). | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom de projet pour le tagging Name. | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block du VPC. /16 recommande pour laisser place aux subnets. | `string` | `"10.30.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nat_gateway_public_ip"></a> [nat\_gateway\_public\_ip](#output\_nat\_gateway\_public\_ip) | IP publique de la NAT Gateway (utile pour whitelist outbound). |
| <a name="output_private_app_subnet_ids"></a> [private\_app\_subnet\_ids](#output\_private\_app\_subnet\_ids) | Map AZ -> ID des subnets prives app (consomme par Role 3 pour l ASG). |
| <a name="output_private_db_subnet_ids"></a> [private\_db\_subnet\_ids](#output\_private\_db\_subnet\_ids) | Map AZ -> ID des subnets prives DB (consomme par Role 4 pour RDS). |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | Map AZ -> ID des subnets publics (consomme par Role 3 pour l ALB). |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | CIDR block du VPC, utile pour les regles de SG. |
| <a name="output_vpc_endpoints_security_group_id"></a> [vpc\_endpoints\_security\_group\_id](#output\_vpc\_endpoints\_security\_group\_id) | SG attache aux VPC endpoints (autorise 443 depuis VPC CIDR). |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID du VPC cree. |
<!-- END_TF_DOCS -->