output "bucket" {
  description = "Nombre del bucket de copias"
  value       = aws_s3_bucket.copias.id
}

output "restic_repositorio" {
  description = "Valor de RESTIC_REPOSITORY para la copia remota (va en /root/secretos/aws-s3.env del servidor)"
  value       = "s3:s3.${var.region}.amazonaws.com/${aws_s3_bucket.copias.id}/restic"
}
