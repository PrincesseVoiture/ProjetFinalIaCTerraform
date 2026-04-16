variable "aws_region" {
  description = "Region AWS (impose : eu-west-1 pour RGPD)."
  type        = string
  default     = "eu-west-3"

  validation {
    condition     = var.aws_region == "eu-west-3"
    error_message = "La region doit etre eu-west-3 (exigence T1 du CdC)."
  }
}

variable "allowed_admin_cidr" {
  description = "CIDR IP autorise a atteindre l ALB en HTTPS (IP formateur)."
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_admin_cidr, 0))
    error_message = "Doit etre un CIDR IPv4 valide (ex: 203.0.113.42/32)."
  }
}

variable "project_name" {
  description = "Nom de projet pour le tagging."
  type        = string
  default     = "kolab"
}

variable "environment" {
  description = "Nom de l environnement."
  type        = string
  default     = "dev"
}
