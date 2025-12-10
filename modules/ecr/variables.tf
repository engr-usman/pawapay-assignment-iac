variable "repo_name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "image_tag_mutability" {
  type        = string
  default     = "MUTABLE"
  description = "Set to IMMUTABLE to prevent overwriting tags"
}

variable "scan_on_push" {
  type        = bool
  default     = true
  description = "Enable vulnerability scanning on image push"
}

variable "encryption_type" {
  type        = string
  default     = "AES256" # options: AES256 or KMS
}

variable "tags" {
  type        = map(string)
  default     = {}
}