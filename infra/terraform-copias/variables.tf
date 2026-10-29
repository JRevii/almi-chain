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
