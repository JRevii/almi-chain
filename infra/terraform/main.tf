# Imagen: la Ubuntu 24.04 LTS oficial más reciente (cuenta de Canonical)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# Se usa la VPC por defecto de la cuenta del laboratorio
data "aws_vpc" "default" {
  default = true
}

# Cortafuegos: web abierta a todos, SSH solo desde tu IP (mínimos privilegios)
resource "aws_security_group" "web" {
  name        = "almichain-web-sg"
  description = "Web Almi-Chain: HTTP y HTTPS publicos, SSH solo admin"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP (redirige a HTTPS y valida Lets Encrypt)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH solo desde la IP del administrador"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    description = "Salida para actualizaciones, DuckDNS y Lets Encrypt"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IP fija: así DuckDNS no cambia aunque se pare y arranque la instancia
resource "aws_eip" "web" {
  domain = "vpc"
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web.id]

  # Configuración automática al primer arranque: Nginx, DuckDNS y HTTPS
  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    domain        = "${var.duckdns_subdomain}.duckdns.org"
    subdomain     = var.duckdns_subdomain
    duckdns_token = var.duckdns_token
    email         = var.certbot_email
  })
  user_data_replace_on_change = true

  # IMDSv2 obligatorio (configuración segura por defecto)
  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "almichain-web"
  }
}

resource "aws_eip_association" "web" {
  instance_id   = aws_instance.web.id
  allocation_id = aws_eip.web.id
}

# Publicar la carpeta web/ del repositorio.
# Se vuelve a ejecutar sola en cada "terraform apply" si cambia cualquier archivo de web/.
locals {
  web_files = fileset(var.web_dir, "**")
  web_hash  = sha1(join("", [for f in local.web_files : filesha1("${var.web_dir}/${f}")]))
}

resource "terraform_data" "web" {
  triggers_replace = [local.web_hash, aws_instance.web.id]
  depends_on       = [aws_eip_association.web]

  connection {
    type        = "ssh"
    host        = aws_eip.web.public_ip
    user        = "ubuntu"
    private_key = file(pathexpand(var.private_key_path))
    timeout     = "5m"
  }

  # Esperar a que termine el primer arranque (Nginx y HTTPS)
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait > /dev/null || true",
      "rm -rf /tmp/web && mkdir -p /tmp/web",
    ]
  }

  provisioner "file" {
    source      = "${var.web_dir}/"
    destination = "/tmp/web"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /var/www/almichain/*",
      "sudo cp -r /tmp/web/. /var/www/almichain/",
      "sudo rm -f /var/www/almichain/README.md",
      "sudo chown -R www-data:www-data /var/www/almichain",
      "sudo find /var/www/almichain -type d -exec chmod 755 {} +",
      "sudo find /var/www/almichain -type f -exec chmod 644 {} +",
      "rm -rf /tmp/web",
    ]
  }
}
