resource "aws_s3_bucket" "buckets" {
  bucket = var.bucket_name
  
  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "buckets-publics" {
  bucket = aws_s3_bucket.buckets.id
  
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}


resource "aws_s3_bucket_versioning" "buckets-versioning" {
  bucket = aws_s3_bucket.buckets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket-lifecycle" {
  count = var.lifecycle_config != null ? 1 : 0

  bucket = var.bucket_name

  rule {
    id     = "s3-logs-lifecycle-rule"
    status = var.lifecycle_config.enable_lifecycle_rule ? "Enabled" : "Disabled"

    # 1. Transition a Standard-IA (Se ejecuta si NO es directo a Glacier)
    dynamic "transition" {
      for_each = var.lifecycle_config.enable_direct_glacier ? [] : [1]
      content {
        days          = var.lifecycle_config.transition_days_standard_ia
        storage_class = "STANDARD_IA"
      }
    }

    # 2. Transition a Glacier Flexible / Instant Retrieval (Estándar)
    # Convertido a dynamic para que solo se aplique si NO es directo a Glacier
    dynamic "transition" {
      for_each = var.lifecycle_config.enable_direct_glacier ? [] : [1]
      content {
        days          = var.lifecycle_config.transition_days_glacier
        storage_class = "GLACIER_IR"
      }
    }

    # 3. Transition directo a Glacier Flexible (Para capas Gold / Directas)
    dynamic "transition" {
      for_each = var.lifecycle_config.enable_direct_glacier ? [1] : []
      content {
        days          = var.lifecycle_config.transition_days_glacier_direct
        storage_class = "GLACIER"
      }
    }

    # 4. Gestión de Versiones No Actuales (Noncurrent)
    noncurrent_version_transition {
      noncurrent_days = var.lifecycle_config.noncurrent_version_transition_days
      storage_class   = "GLACIER_IR"
    }

    noncurrent_version_expiration {
      noncurrent_days = var.lifecycle_config.noncurrent_version_expiration_days
    }

    # 5. Limpieza de objetos intermedios o incompletos
    filter {
      # Bloque vacío requerido por AWS para aplicar la regla a todo el bucket
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = var.lifecycle_config.abort_incomplete_multipart_upload_days
    }
  }
}