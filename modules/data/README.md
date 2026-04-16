# Module `data`

Couche persistance : RDS PostgreSQL + 2 buckets S3.

Créé par le **Rôle 4 — Data Engineer** lors du TP05.

## Contenu attendu

- RDS PostgreSQL 16.4 Multi-AZ, chiffré KMS, db.t3.micro
- Bucket S3 `primary` : stockage fichiers Nextcloud (versioning + SSE-KMS)
- Bucket S3 `logs` : access logs ALB (SSE-AES256 — ALB ne supporte pas KMS ici), lifecycle Glacier/expiration

## Interface

Voir `variables.tf` et `outputs.tf`.

Consultez [role-4-data.md](../../../cours/jour5/tp05-team-nextcloud/role-4-data.md) pour le détail.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.nextcloud](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_parameter_group.nextcloud](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_db_subnet_group.nextcloud](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_s3_bucket.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [random_pet.bucket_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_elb_service_account.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account) | data source |
| [aws_iam_policy_document.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.primary_deny_insecure](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_secretsmanager_secret_version.db_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_db_allocated_storage"></a> [db\_allocated\_storage](#input\_db\_allocated\_storage) | Storage initial RDS en Go. | `number` | `20` | no |
| <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version) | Version PostgreSQL. | `string` | `"16.4"` | no |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | Classe d instance RDS. db.t3.micro = plus petit dispo Multi-AZ. | `string` | `"db.t3.micro"` | no |
| <a name="input_db_max_allocated_storage"></a> [db\_max\_allocated\_storage](#input\_db\_max\_allocated\_storage) | Storage max (auto-scaling gp3) pour absorber les uploads Nextcloud. | `number` | `100` | no |
| <a name="input_db_password_secret_arn"></a> [db\_password\_secret\_arn](#input\_db\_password\_secret\_arn) | ARN du secret Secrets Manager contenant le mot de passe DB. | `string` | n/a | yes |
| <a name="input_db_security_group_id"></a> [db\_security\_group\_id](#input\_db\_security\_group\_id) | SG attache au RDS (fourni par le module security). | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Nom de l environnement. | `string` | `"dev"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN de la CMK KMS (fournie par le module security). | `string` | n/a | yes |
| <a name="input_private_db_subnet_ids"></a> [private\_db\_subnet\_ids](#input\_private\_db\_subnet\_ids) | Map AZ -> subnet\_id prive DB (2 subnets sur 2 AZ pour Multi-AZ). | `map(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom de projet pour le tagging. | `string` | `"kolab"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID du VPC (output du module networking). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_endpoint"></a> [db\_endpoint](#output\_db\_endpoint) | Hostname RDS (sans port). |
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | Nom de la base logique. |
| <a name="output_db_port"></a> [db\_port](#output\_db\_port) | Port PostgreSQL (5432). |
| <a name="output_db_username"></a> [db\_username](#output\_db\_username) | User master PostgreSQL. |
| <a name="output_s3_logs_bucket_arn"></a> [s3\_logs\_bucket\_arn](#output\_s3\_logs\_bucket\_arn) | ARN du bucket logs. |
| <a name="output_s3_logs_bucket_name"></a> [s3\_logs\_bucket\_name](#output\_s3\_logs\_bucket\_name) | Nom du bucket access logs ALB. |
| <a name="output_s3_primary_bucket_arn"></a> [s3\_primary\_bucket\_arn](#output\_s3\_primary\_bucket\_arn) | ARN du bucket primary (consomme par envs/dev pour scoper la policy IAM app). |
| <a name="output_s3_primary_bucket_name"></a> [s3\_primary\_bucket\_name](#output\_s3\_primary\_bucket\_name) | Nom du bucket primary storage. |
<!-- END_TF_DOCS -->