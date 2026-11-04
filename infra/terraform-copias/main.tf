# Bucket S3 para la copia REMOTA de restic (regla 3-2-1: RAID + disco C + nube).
# Va en una carpeta aparte de la web para que un "terraform destroy" de la web
# no pueda borrar las copias.
#
# AWS Academy (Learner Lab): una política de la organización (SCP) prohíbe
# s3:GetBucketObjectLockConfiguration, y el recurso aws_s3_bucket del proveedor
# lo consulta siempre al crear o leer el bucket, así que falla con AccessDenied.
# Por eso el bucket se crea con un solo comando de AWS CLI (ver README) y
# Terraform gestiona toda su configuración de seguridad.

locals {
  bucket     = var.bucket
  bucket_arn = "arn:aws:s3:::${var.bucket}"
}

# Nadie de fuera: sin ACL ni políticas públicas
resource "aws_s3_bucket_public_access_block" "copias" {
  bucket                  = local.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "copias" {
  bucket = local.bucket
  rule {
    object_ownership = "BucketOwnerEnforced" # sin ACL, solo permisos de IAM
  }
}

# Cifrado en reposo en S3 (además, restic ya cifra con AES-256 antes de subir)
resource "aws_s3_bucket_server_side_encryption_configuration" "copias" {
  bucket = local.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Versionado: si alguien borra o sobrescribe la copia, la versión anterior sigue ahí
resource "aws_s3_bucket_versioning" "copias" {
  bucket = local.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "copias" {
  bucket     = local.bucket
  depends_on = [aws_s3_bucket_versioning.copias]

  rule {
    id     = "limpiar-versiones-antiguas"
    status = "Enabled"
    filter {}
    noncurrent_version_expiration {
      noncurrent_days = var.dias_versiones_antiguas
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Solo por HTTPS: se rechaza cualquier petición sin cifrar
data "aws_iam_policy_document" "solo_https" {
  statement {
    sid     = "SoloHTTPS"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      local.bucket_arn,
      "${local.bucket_arn}/*",
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "copias" {
  bucket     = local.bucket
  policy     = data.aws_iam_policy_document.solo_https.json
  depends_on = [aws_s3_bucket_public_access_block.copias]
}
