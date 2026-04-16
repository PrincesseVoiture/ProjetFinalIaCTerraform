# Module `security`

Centralise la sécurité : KMS CMK, 3 Security Groups, 2 secrets Manager, IAM role + instance profile.

Créé par le **Rôle 5 — Security Engineer** lors du TP05.

## Contenu attendu

- **KMS** : 1 CMK avec rotation annuelle + alias
- **Security Groups** : alb (public 443/80), app (depuis alb), db (depuis app 5432)
- **Secrets Manager** : 2 secrets (db_password 24c, admin_password 20c) chiffrés KMS
- **IAM** : role assumable par EC2 + instance profile + policies scopées

## Interface

Voir `variables.tf` (inputs) et `outputs.tf` (outputs exposés).

Consultez [role-5-security.md](../../../cours/jour5/tp05-team-nextcloud/role-5-security.md) pour les étapes détaillées.

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
| [aws_iam_instance_profile.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.app_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.app_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.app_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.app_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.app_ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_secretsmanager_secret.admin_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.db_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.admin_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.db_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.alb_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.app_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.db_minimal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.alb_http_redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.alb_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.app_http_from_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.db_pg_from_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_password.admin](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.db](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.app_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.app_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.app_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.app_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_admin_cidr"></a> [allowed\_admin\_cidr](#input\_allowed\_admin\_cidr) | CIDR autorise pour l acces admin (IP formateur). Non utilise pour l instant mais figes au contrat. | `string` | `"0.0.0.0/0"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environnement (dev, staging, prod). | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nom du projet (prefixe de nommage). | `string` | n/a | yes |
| <a name="input_s3_primary_bucket_arn"></a> [s3\_primary\_bucket\_arn](#input\_s3\_primary\_bucket\_arn) | n/a | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR du VPC (fourni par le module networking). | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID du VPC (fourni par le module networking). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_password_secret_arn"></a> [admin\_password\_secret\_arn](#output\_admin\_password\_secret\_arn) | ARN du secret Secrets Manager contenant le password admin Nextcloud. |
| <a name="output_alb_security_group_id"></a> [alb\_security\_group\_id](#output\_alb\_security\_group\_id) | Security Group ID pour l ALB. |
| <a name="output_app_iam_role_arn"></a> [app\_iam\_role\_arn](#output\_app\_iam\_role\_arn) | ARN du role IAM de l application. |
| <a name="output_app_iam_role_name"></a> [app\_iam\_role\_name](#output\_app\_iam\_role\_name) | Nom du role IAM de l application (utile pour attacher des policies inline depuis envs/dev). |
| <a name="output_app_instance_profile_name"></a> [app\_instance\_profile\_name](#output\_app\_instance\_profile\_name) | Nom de l instance profile a attacher a l ASG. |
| <a name="output_app_security_group_id"></a> [app\_security\_group\_id](#output\_app\_security\_group\_id) | Security Group ID pour les EC2 app. |
| <a name="output_db_password_secret_arn"></a> [db\_password\_secret\_arn](#output\_db\_password\_secret\_arn) | ARN du secret Secrets Manager contenant le password RDS. |
| <a name="output_db_security_group_id"></a> [db\_security\_group\_id](#output\_db\_security\_group\_id) | Security Group ID pour RDS. |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN de la KMS CMK principale. |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | ID de la KMS CMK principale. |
<!-- END_TF_DOCS -->