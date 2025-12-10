terraform {
  backend "s3" {}
}

provider "aws" {
  alias  = "rds"
  region = var.region
}

######################################
# DB Subnet Group
######################################

resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.db_name}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = merge(var.tags, { Name = "${var.db_name}-subnet-group" })
}

######################################
# Parameter Group
######################################

resource "aws_db_parameter_group" "pg" {
  name        = "${var.db_name}-pg"
  family      = "postgres15"
  description = "Custom Parameter Group"

  tags = merge(var.tags, { Name = "${var.db_name}-pg" })
}

resource "random_password" "db_pass" {
  length  = 16
  special = false
  override_special = "!#$%^&*()-_=+[]{}<>?|~"
}

resource "aws_secretsmanager_secret_version" "rds_creds" {
  secret_id = var.secret_arn
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.db_pass.result
  })
}

######################################
# RDS INSTANCE
######################################

resource "aws_db_instance" "this" {
  identifier = var.db_name

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_name  = var.db_name
  username = var.master_username
  password = random_password.db_pass.result

  allocated_storage = var.allocated_storage
  max_allocated_storage = var.allocated_storage + 50

  multi_az = true

  storage_type = "gp3"
  publicly_accessible = false

  db_subnet_group_name = aws_db_subnet_group.db_subnets.name
  parameter_group_name = aws_db_parameter_group.pg.name
  vpc_security_group_ids = [aws_security_group.db.id]

  skip_final_snapshot = true
  deletion_protection = false

  tags = var.tags
}

resource "aws_security_group" "db" {
  name        = "assignment-db-sg"
  description = "DB access only from EKS nodes"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow VPC internal traffic to Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "assignment-db-sg"
  })
}