variable "region" {
  description = "Región de AWS. AWS Academy Learner Lab solo deja us-east-1 y us-west-2."
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tipo de instancia. t3.micro basta para una web estática con Nginx."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Par de claves para SSH. En el Learner Lab ya existe 'vockey' (labsuser.pem)."
  type        = string
  default     = "vockey"
}

variable "admin_cidr" {
  description = "Tu IP pública con /32 (curl ifconfig.me). Solo esa IP podrá entrar por SSH."
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0)) && var.admin_cidr != "0.0.0.0/0"
    error_message = "Pon tu IP con /32, por ejemplo 83.45.12.7/32. No se permite 0.0.0.0/0 para SSH."
  }
}

variable "duckdns_subdomain" {
  description = "Solo el nombre del subdominio, sin .duckdns.org (por ejemplo: almichain)."
  type        = string
}

variable "duckdns_token" {
  description = "Token de tu cuenta de DuckDNS. Secreto: va en terraform.tfvars, que no se sube a Git."
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "Ruta a labsuser.pem (AWS Details → Download PEM). Terraform la usa para subir la web."
  type        = string
  default     = "~/.ssh/labsuser.pem"
}

variable "web_dir" {
  description = "Carpeta de la web dentro del repositorio."
  type        = string
  default     = "../../web"
}

variable "certbot_email" {
  description = "Email para Let's Encrypt (avisos de caducidad del certificado)."
  type        = string
}
