# =============================================================================
# modules/data/s3.tf
# 2 buckets S3 :
#   - primary : stockage des fichiers Nextcloud (chiffre KMS, versioning)
#   - logs    : logs d acces ALB (SSE-AES256 obligatoire — ALB refuse SSE-KMS)
# =============================================================================
# Pour CHAQUE bucket, declarer :
#
#   - aws_s3_bucket                               (le bucket)
#   - aws_s3_bucket_versioning                    (enabled)          [primary uniquement]
#   - aws_s3_bucket_server_side_encryption_configuration
#   - aws_s3_bucket_public_access_block           (les 4 a true)
#   - aws_s3_bucket_policy                        (deny non-TLS + specifique ALB pour logs)
#
# Pour le bucket "logs" uniquement : aws_s3_bucket_lifecycle_configuration
#   - transition vers GLACIER_IR a 30 jours
#   - expiration a 90 jours
# =============================================================================

# -----------------------------------------------------------------------------
# BUCKET PRIMARY (stockage fichiers Nextcloud)
# -----------------------------------------------------------------------------

# TODO(role-4) : aws_s3_bucket "primary"
#   bucket = "${local.name_prefix}-nextcloud-${random_id.suffix.hex}"
#   force_destroy = true    (dev uniquement — permet destroy meme si bucket non-vide)

# TODO(role-4) : aws_s3_bucket_versioning "primary"
#   versioning_configuration { status = "Enabled" }

# TODO(role-4) : aws_s3_bucket_server_side_encryption_configuration "primary"
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm     = "aws:kms"
#       kms_master_key_id = var.kms_key_arn
#     }
#     bucket_key_enabled = true
#   }

# TODO(role-4) : aws_s3_bucket_public_access_block "primary"
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true

# TODO(role-4) : aws_s3_bucket_policy "primary"
#   policy : deny si aws:SecureTransport = false

# -----------------------------------------------------------------------------
# BUCKET LOGS (access logs ALB)
# -----------------------------------------------------------------------------

# 🟡 ATTENTION : l ALB ne sait pas ecrire dans un bucket chiffre SSE-KMS
#   (limitation AWS documentee). On utilise SSE-AES256 pour ce bucket uniquement.

# TODO(role-4) : aws_s3_bucket "logs"

# TODO(role-4) : aws_s3_bucket_server_side_encryption_configuration "logs"
#   avec sse_algorithm = "AES256" (pas KMS !)

# TODO(role-4) : aws_s3_bucket_public_access_block "logs"

# TODO(role-4) : aws_s3_bucket_policy "logs"
#   Doit autoriser data.aws_elb_service_account.main.arn a PutObject.
#   Pattern :
#     data "aws_iam_policy_document" "alb_logs" {
#       statement {
#         principals {
#           type        = "AWS"
#           identifiers = [data.aws_elb_service_account.main.arn]
#         }
#         actions   = ["s3:PutObject"]
#         resources = ["${aws_s3_bucket.logs.arn}/*"]
#       }
#       # + statement deny non-TLS
#     }

# TODO(role-4) : aws_s3_bucket_lifecycle_configuration "logs"
#   rule {
#     id     = "archive-30d-expire-90d"
#     status = "Enabled"
#     transition { days = 30  storage_class = "GLACIER_IR" }
#     expiration { days = 90 }
#   }

# -----------------------------------------------------------------------------
# Bucket primary : stockage fichiers Nextcloud
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "primary" {
  bucket        = local.primary_bucket_name
  force_destroy = true # 🟡 TP only - permet destroy avec objets presents

  tags = merge(local.common_tags, {
    Name = local.primary_bucket_name
    Role = "nextcloud-primary-storage"
  })
}

# Versioning : permet de restaurer un fichier ecrase
resource "aws_s3_bucket_versioning" "primary" {
  bucket = aws_s3_bucket.primary.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Chiffrement SSE-KMS avec la CMK du module security
resource "aws_s3_bucket_server_side_encryption_configuration" "primary" {
  bucket = aws_s3_bucket.primary.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    # bucket_key reduit les couts KMS (mutualisation)
    bucket_key_enabled = true
  }
}

# Block Public Access 4/4 (jamais exposer les fichiers avocats !)
resource "aws_s3_bucket_public_access_block" "primary" {
  bucket = aws_s3_bucket.primary.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# Bucket policy : deny toute requete non HTTPS
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "primary_deny_insecure" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.primary.arn,
      "${aws_s3_bucket.primary.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "primary" {
  bucket = aws_s3_bucket.primary.id
  policy = data.aws_iam_policy_document.primary_deny_insecure.json

  # IMPORTANT : BPA doit etre pose AVANT la policy, sinon AWS refuse
  depends_on = [aws_s3_bucket_public_access_block.primary]
}

# -----------------------------------------------------------------------------
# Data source : compte AWS canonique ELB pour la region courante
# -----------------------------------------------------------------------------
data "aws_elb_service_account" "main" {}

# -----------------------------------------------------------------------------
# Bucket logs ALB
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "logs" {
  bucket        = local.logs_bucket_name
  force_destroy = true # 🟡 TP only

  tags = merge(local.common_tags, {
    Name = local.logs_bucket_name
    Role = "alb-access-logs"
  })
}

# Chiffrement SSE-KMS (meme CMK que le primary)
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

# Block Public Access 4/4
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# Bucket policy : autorise le compte AWS ELB de la region a PutObject
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "logs" {
  # Statement 1 : autorise l ALB a ecrire ses logs
  statement {
    sid    = "AllowELBAccessLogs"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }

    actions = ["s3:PutObject"]

    resources = [
      "${aws_s3_bucket.logs.arn}/alb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]
  }

  # Statement 2 : deny tout le reste non HTTPS (defense en profondeur)
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.logs.arn,
      "${aws_s3_bucket.logs.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.logs.json

  depends_on = [aws_s3_bucket_public_access_block.logs]
}

# -----------------------------------------------------------------------------
# Lifecycle : logs -> Glacier IR a J+30, expires a J+90
# -----------------------------------------------------------------------------
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "alb-logs-lifecycle"
    status = "Enabled"

    filter {
      prefix = "alb/"
    }

    # Transition vers Glacier Instant Retrieval apres 30 jours
    transition {
      days          = 30
      storage_class = "GLACIER_IR"
    }

    # Expiration apres 90 jours
    expiration {
      days = 90
    }

    # Les versions non-current expirent a 7 jours
    noncurrent_version_expiration {
      noncurrent_days = 7
    }

    # Nettoyage des multipart uploads incomplets (cout cache)
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
