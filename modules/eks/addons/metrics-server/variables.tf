variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "namespace" {
  type        = string
  default     = "kube-system"
}