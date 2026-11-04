terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Credenciales: las temporales de AWS Academy (AWS Details → AWS CLI),
# copiadas en ~/.aws/credentials. Nunca se escriben aquí.
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Proyecto = "Almi-Chain"
      Reto     = "Reto1-ASIR1"
      Gestion  = "Terraform"
      Uso      = "Copias de seguridad"
    }
  }
}
