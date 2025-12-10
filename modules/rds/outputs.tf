output "db_endpoint" {
  value = aws_db_instance.this.address
}

output "db_port" {
  value = aws_db_instance.this.port
}

output "db_name" {
  value = aws_db_instance.this.db_name
}

output "db_username" {
  value = var.master_username
}

output "db_host" {
  value = aws_db_instance.this.address
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}