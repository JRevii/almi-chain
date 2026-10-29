variable "bucket" {
  description = "Nombre del bucket de copias, creado antes con AWS CLI (ver README). Ejemplo: almichain-copias-20261029083519995800000001"
  type        = string

  validation {
    condition     = can(regex("^almichain-copias-[a-z0-9-]+$", var.bucket))
    error_message = "El bucket tiene que llamarse almichain-copias-<algo>, en minúsculas."
  }
}

variable "region" {
  description = "Región de AWS. AWS Academy Learner Lab solo deja us-east-1 y us-west-2."
  type        = string
  default     = "us-east-1"
}

variable "dias_versiones_antiguas" {
  description = "Días que se guardan las versiones antiguas o borradas de cada objeto antes de eliminarlas."
  type        = number
  default     = 30
}
