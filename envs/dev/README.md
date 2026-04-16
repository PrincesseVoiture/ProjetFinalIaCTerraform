<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_compute"></a> [compute](#module\_compute) | ../../modules/compute | n/a |
| <a name="module_data"></a> [data](#module\_data) | ../../modules/data | n/a |
| <a name="module_networking"></a> [networking](#module\_networking) | ../../modules/networking | n/a |
| <a name="module_security"></a> [security](#module\_security) | ../../modules/security | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_admin_cidr"></a> [allowed\_admin\_cidr](#input\_allowed\_admin\_cidr) | CIDR IP autorise a atteindre l ALB en HTTPS (IP formateur). | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region AWS (impose : eu-west-1 pour RGPD). | `string` | `"eu-west-3"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Nom de l environnement. | `string` | `"dev"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom de projet pour le tagging. | `string` | `"kolab"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_password_secret_arn"></a> [admin\_password\_secret\_arn](#output\_admin\_password\_secret\_arn) | ARN Secrets Manager du password admin Nextcloud. |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS public de l ALB, a utiliser pour acceder a Nextcloud. |
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | Nom de l ASG applicatif. |
| <a name="output_db_endpoint"></a> [db\_endpoint](#output\_db\_endpoint) | Hostname RDS (non public). |
| <a name="output_db_password_secret_arn"></a> [db\_password\_secret\_arn](#output\_db\_password\_secret\_arn) | ARN Secrets Manager du password DB (lecture via aws secretsmanager). |
| <a name="output_nextcloud_url"></a> [nextcloud\_url](#output\_nextcloud\_url) | URL complete HTTPS de Nextcloud (self-signed : avertissement navigateur). |
| <a name="output_s3_logs_bucket_name"></a> [s3\_logs\_bucket\_name](#output\_s3\_logs\_bucket\_name) | Bucket S3 access logs ALB. |
| <a name="output_s3_primary_bucket_name"></a> [s3\_primary\_bucket\_name](#output\_s3\_primary\_bucket\_name) | Bucket S3 primary storage Nextcloud. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID du VPC (debug). |
<!-- END_TF_DOCS -->