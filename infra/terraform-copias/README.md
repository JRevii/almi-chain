# Bucket S3 para la copia remota (Terraform)

Crea el bucket de AWS S3 donde va la **copia remota** de restic del servidor Odoo. Con esto el plan de copias cumple la regla **3-2-1**: los datos en el RAID 1, una copia en el disco C del servidor y otra fuera del local, en la nube.

Está en una carpeta aparte de [`../terraform/`](../terraform) (la web) a propósito: así un `terraform destroy` de la web nunca puede borrar las copias.

## Qué crea

| Recurso | Para qué |
| --- | --- |
| `aws_s3_bucket.copias` | Bucket `almichain-copias-<sufijo>`. `force_destroy = false`: no se puede borrar mientras tenga copias |
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
cd infra/terraform-copias
terraform init
terraform validate
terraform plan        # 7 recursos
terraform apply
terraform output      # bucket y restic_repositorio
```

El valor de `restic_repositorio` es el que va en el servidor (ver [`backups/README.md`](../../backups/README.md#4-copia-remota-en-aws-s3)).

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
