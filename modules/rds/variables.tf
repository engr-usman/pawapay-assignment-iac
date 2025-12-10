variable "db_name" {
  type        = string
  description = "Database name"
}

variable "secret_arn" {
  type = string
}

variable "master_username" {
  type = string
}

variable "engine_version" {
  type        = string
  default     = "15.3"
}

variable "instance_class" {
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  type        = number
  default     = 20
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnets for DB subnet group"
}

variable "vpc_id" {
  type = string
}

variable "region" { 
  type = string 
}

variable "tags" {
  type        = map(string)
  default     = {}
}