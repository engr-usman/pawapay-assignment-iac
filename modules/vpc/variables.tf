variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnets" {
  type        = list(string)
  description = "CIDRs for public subnets"
}

variable "private_subnets" {
  type        = list(string)
  description = "CIDRs for private subnets"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones for the subnets"
}

variable "enable_nat_gateway" {
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  type        = bool
  default     = true
}

variable "tags" {
  type        = map(string)
  default     = {}
}