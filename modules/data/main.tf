# =============================================================================
# modules/data/main.tf
# ROLE 4 (Data Engineer) — data sources + ressources partagees du module.
# =============================================================================
# OBJECTIF : centraliser RDS + les 2 buckets S3 (primary + ALB logs).
#
# Fichiers de ce module :
#   - rds.tf  : RDS PostgreSQL Multi-AZ + DB subnet group + parameter group
#   - s3.tf   : 2 buckets S3 (primary Nextcloud storage + ALB access logs)
#
# Ce fichier main.tf contient les data sources partages entre rds.tf et s3.tf.
# =============================================================================

# TODO(role-4) : data sources partages.
#
# Exemple :
#   data "aws_secretsmanager_secret_version" "db_password" {
#     secret_id = var.db_password_secret_arn
#   }
#
#   data "aws_elb_service_account" "main" {}   # pour bucket policy ALB logs
#
#   data "aws_caller_identity" "current" {}
#
#   data "aws_region" "current" {}
#
# Et (optionnel) un suffixe aleatoire pour l unicite globale des noms S3 :
#   resource "random_id" "suffix" {
#     byte_length = 4
#   }

data "aws_caller_identity" "current" {}

resource "random_pet" "bucket_suffix" {
  length    = 2
  separator = "-"
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # Noms globalement uniques pour S3 (account_id + random_pet)
  primary_bucket_name = "${local.name_prefix}-primary-${data.aws_caller_identity.current.account_id}-${random_pet.bucket_suffix.id}"
  logs_bucket_name    = "${local.name_prefix}-alb-logs-${data.aws_caller_identity.current.account_id}-${random_pet.bucket_suffix.id}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Module      = "data"
  }
}
