variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "cluster_version" {
  type        = string
  default     = "1.32"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "vpc_cidr" {}

variable "cluster_endpoint_public_access" {
  default = true
}

variable "cluster_endpoint_private_access" {
  default = true
}

variable "cluster_endpoint_public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

# Node group variables
variable "instance_type" {}
variable "desired_size" {}
variable "min_size" {}
variable "max_size" {}
variable "ssh_key_name" {}
variable "disk_size" {
  default = 50
}


variable "tags" {
  type        = map(string)
  default     = {}
}