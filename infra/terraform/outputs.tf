output "ip_publica" {
  description = "IP fija (Elastic IP) de la web"
  value       = aws_eip.web.public_ip
}

output "url" {
  description = "Dirección de la web"
  value       = "https://${var.duckdns_subdomain}.duckdns.org"
}

output "ssh" {
  description = "Comando para entrar por SSH"
  value       = "ssh -i ~/.ssh/labsuser.pem ubuntu@${aws_eip.web.public_ip}"
}
