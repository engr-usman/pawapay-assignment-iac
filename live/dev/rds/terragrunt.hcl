include "root" {
  path = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../modules/rds//"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  db_name   = "assignmentdb"
  region = include.root.locals.region

  engine_version     = "15.15"
  instance_class     = "db.t3.micro"
  allocated_storage  = 40

  vpc_id           = dependency.vpc.outputs.vpc_id
  vpc_cidr         = dependency.vpc.outputs.vpc_cidr

  subnet_ids = dependency.vpc.outputs.private_subnets

  secret_arn       = "arn:aws:secretsmanager:us-east-1:821106082324:secret:assignment/rds/creds-WczeZc"
  master_username  = "assignmentuser"

  tags = include.root.locals.common_tags
}