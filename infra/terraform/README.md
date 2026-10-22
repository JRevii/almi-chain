# Infraestructura en AWS (Terraform)

Despliegue reproducible de la web en AWS con Terraform, Nginx con HTTPS y dominio DuckDNS. Las credenciales nunca se suben: usar `example.tfvars` como plantilla.

```
Internet ──HTTPS──► almichain.duckdns.org ──► Elastic IP ──► EC2 t3.micro · Ubuntu 24.04 · Nginx + Certbot
                                                   Security Group: 80 y 443 abiertos · 22 solo IP del admin
```

Un solo `terraform apply` crea el servidor, lo configura, saca el certificado HTTPS y publica la carpeta [`web/`](../../web).

## Qué crea

| Recurso | Para qué |
| --- | --- |
| `aws_security_group.web` | Cortafuegos: HTTP/HTTPS para todos, SSH solo desde la IP del administrador (validado: no admite `0.0.0.0/0`) |
| `aws_instance.web` | Servidor Ubuntu 24.04 `t3.micro`, disco cifrado, IMDSv2 obligatorio |
| `aws_eip.web` | IP fija, para que el dominio no cambie al parar y arrancar |
| `user_data.sh.tftpl` | Primer arranque: Nginx con compresión, caché y cabeceras de seguridad; DuckDNS cada 5 min; certificado Let's Encrypt y redirección HTTP → HTTPS; renovación automática |
| `terraform_data.web` | Sube `web/` al servidor. Se repite sola en cada `apply` si cambia algún archivo de la web |

## Requisitos

- Terraform ≥ 1.5 y AWS CLI en el portátil.
- Cuenta en [duckdns.org](https://www.duckdns.org) con un subdominio creado y su token.
- Learner Lab de AWS Academy iniciado (semáforo en verde).

## Pasos para reproducir

1. **Credenciales del laboratorio.** Caducan en cada sesión, así que hay que repetirlo cada vez. En el Learner Lab: *AWS Details → AWS CLI → Show*. Copia el bloque en `~/.aws/credentials` y comprueba con `aws sts get-caller-identity`.
2. **Clave SSH.** En *AWS Details → Download PEM*:
   ```bash
   mv ~/Descargas/labsuser.pem ~/.ssh/ && chmod 400 ~/.ssh/labsuser.pem
   ```
3. **Variables.**
   ```bash
   cd infra/terraform
   cp example.tfvars terraform.tfvars
   curl ifconfig.me          # tu IP → admin_cidr = "x.x.x.x/32"
   ```
   Rellena `terraform.tfvars`. No se sube a Git.
4. **Desplegar.**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```
   El `apply` tarda unos 5–10 minutos, porque espera a que el servidor termine de configurarse antes de subir la web.
5. **Comprobar.** Abre la dirección de `terraform output url`. Si algo falla, mira el registro del primer arranque:
   ```bash
   ssh -i ~/.ssh/labsuser.pem ubuntu@$(terraform output -raw ip_publica) 'sudo cat /var/log/almichain-setup.log'
   ```
6. **Actualizar la web.** Tras cambiar algo en `web/`, basta con volver a ejecutar `terraform apply`.

## Ahorrar crédito del laboratorio

- Al terminar la sesión, el laboratorio para la instancia solo. La Elastic IP y el disco se mantienen, y al volver la web sigue en el mismo dominio.
- **Si cambia tu IP** (otra red, clase o casa), actualiza `admin_cidr` y haz `terraform apply`. Si no, SSH y la subida de la web no conectan.
- Para borrarlo todo: `terraform destroy`.
- `terraform.tfstate` se queda **solo en el portátil de quien despliega**. No se sube a Git, porque guarda el token. Si se pierde, hay que borrar los recursos a mano en la consola.

## Pruebas (evidencias para la documentación)

```bash
IP=$(terraform output -raw ip_publica); URL=$(terraform output -raw url)
curl -I http://$IP                       # 301 → https
curl -I $URL                             # 200, con Content-Security-Policy y Strict-Transport-Security
curl -sI -H 'Accept-Encoding: gzip' $URL/css/styles.css | grep -i -e content-encoding -e expires
echo | openssl s_client -connect ${URL#https://}:443 2>/dev/null | openssl x509 -noout -issuer -dates
nmap -Pn -p 22,80,443 $IP                # desde otra red: 22 filtrado
```

Para comparar con la prueba local, pasa Lighthouse sobre la URL pública. También se pueden revisar las cabeceras con [securityheaders.com](https://securityheaders.com).
