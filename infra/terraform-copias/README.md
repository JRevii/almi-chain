# Bucket S3 para la copia remota (Terraform)

Crea el bucket de AWS S3 donde va la **copia remota** de restic del servidor Odoo. Con esto el plan de copias cumple la regla **3-2-1**: los datos en el RAID 1, una copia en el disco C del servidor y otra fuera del local, en la nube.

Está en una carpeta aparte de [`../terraform/`](../terraform) (la web) a propósito: así un `terraform destroy` de la web nunca puede borrar las copias.

## Qué crea

| Recurso | Para qué |
| --- | --- |
| Bucket `almichain-copias-<sufijo>` | Se crea con **AWS CLI**, no con Terraform (ver la incidencia de abajo) |
| `aws_s3_bucket_public_access_block` | Bloquea cualquier acceso público |
| `aws_s3_bucket_ownership_controls` | Sin ACL: solo permisos de IAM |
| `aws_s3_bucket_server_side_encryption_configuration` | Cifrado en reposo (AES-256). Además restic cifra todo antes de subirlo |
| `aws_s3_bucket_versioning` | Si alguien borra o sobrescribe una copia, la versión anterior se conserva |
| `aws_s3_bucket_lifecycle_configuration` | Las versiones antiguas se borran a los 30 días, para no acumular coste |
| `aws_s3_bucket_policy` | Rechaza cualquier petición que no vaya por HTTPS |

## Pasos

```bash
# Learner Lab encendido y credenciales en ~/.aws/credentials (igual que para la web)
aws sts get-caller-identity

# 1. Crear el bucket (una sola vez). El nombre tiene que ser único en todo AWS
BUCKET="almichain-copias-$(date +%Y%m%d%H%M%S)"
aws s3api create-bucket --bucket "$BUCKET" --region us-east-1
echo "bucket = \"$BUCKET\"" > infra/terraform-copias/terraform.tfvars

# 2. Configurar su seguridad con Terraform
cd infra/terraform-copias
terraform init
terraform validate
terraform plan        # 6 recursos
terraform apply
terraform output      # bucket y restic_repositorio
```

El valor de `restic_repositorio` es el que va en el servidor (ver [`backups/README.md`](../../backups/README.md#4-copia-remota-en-aws-s3)).

## Incidencia: AccessDenied al crear el bucket con Terraform

| Qué pasó | Causa | Solución |
| --- | --- | --- |
| `terraform apply` creaba el bucket y luego fallaba con `AccessDenied ... s3:GetBucketObjectLockConfiguration ... explicit deny in a service control policy` | En AWS Academy, una política de la organización (SCP) prohíbe consultar el *object lock*. El recurso `aws_s3_bucket` del proveedor de AWS lo consulta siempre después de crear el bucket | El bucket se crea con `aws s3api create-bucket` y Terraform gestiona el resto de la configuración (acceso, cifrado, versionado, ciclo de vida y política), que no necesita ese permiso. En una cuenta normal de AWS, `aws_s3_bucket` funciona sin problema |

## Limitación de AWS Academy y cómo sería en una empresa

En el Learner Lab las credenciales son temporales: caducan al cerrar la sesión y no se puede crear un usuario IAM propio. Por eso la copia remota solo funciona con el lab encendido, y hay que renovar las credenciales del servidor en cada sesión.

En una empresa real se crearía un **usuario IAM solo para las copias**, con una clave fija y permiso **únicamente sobre este bucket** (mínimo privilegio), y el cron haría la copia remota cada noche sin intervención:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow", "Action": ["s3:ListBucket", "s3:GetBucketLocation"],
      "Resource": "arn:aws:s3:::almichain-copias-XXXX" },
    { "Effect": "Allow", "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::almichain-copias-XXXX/*" }
  ]
}
```
