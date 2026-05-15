variable "region" {
  type = string
}

variable "bucket_silver" {
  type = string
}

variable "bucket_gold" {
  type = string
}

variable "tags_silver" {
  default = {}
}

variable "tags_gold" {
  default = {}
}

variable "lifecycle_silver" {
  description = "Lifecycle configuration for silver bucket"
  type = object({
    enable_lifecycle_rule           = bool
    transition_days_standard_ia     = number
    transition_days_glacier         = number
    noncurrent_version_transition_days = number
    noncurrent_version_expiration_days = number
    enable_expired_object_delete_marker = bool
    enable_abort_incomplete_multipart_upload = bool
    abort_incomplete_multipart_upload_days = number
    enable_direct_glacier           = bool
    transition_days_glacier_direct  = number
  })
  default = null
}

variable "lifecycle_gold" {
  description = "Lifecycle configuration for gold bucket"
  type = object({
    enable_lifecycle_rule           = bool
    transition_days_standard_ia     = number
    transition_days_glacier         = number
    noncurrent_version_transition_days = number
    noncurrent_version_expiration_days = number
    enable_expired_object_delete_marker = bool
    enable_abort_incomplete_multipart_upload = bool
    abort_incomplete_multipart_upload_days = number
    enable_direct_glacier           = bool
    transition_days_glacier_direct  = number
  })
  default = null
}
#=========================================================================
#============== variables de bloqueo de bucket ======================
variable "block_public_acls" {
  type = bool
}
variable "block_public_policy" {
  type = bool
}
variable "ignore_public_acls" {
  type = bool
}
variable "restrict_public_buckets" {
  type = bool
}
#=========================================================================