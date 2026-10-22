# Plantilla. Cópiala y rellénala:  cp example.tfvars terraform.tfvars
# terraform.tfvars NO se sube a Git (lo excluye el .gitignore): lleva el token de DuckDNS.

admin_cidr        = "83.45.12.7/32" # tu IP pública: curl ifconfig.me
duckdns_subdomain = "almichain"     # el subdominio creado en duckdns.org
duckdns_token     = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
certbot_email     = "tu-correo@ejemplo.com"
# private_key_path = "~/.ssh/labsuser.pem"    # por defecto ya es esta
