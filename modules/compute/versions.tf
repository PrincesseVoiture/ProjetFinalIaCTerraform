terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
    # Provider TLS pour generer la cle + le cert auto-signe
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
