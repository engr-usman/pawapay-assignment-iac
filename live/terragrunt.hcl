###############################################
# Root Terragrunt Configuration
# Shared settings for all modules/environments
###############################################

locals {
  # Default project-level variables
  project     = "assignment"
  region      = "us-east-1"
  environment = "dev"

  # Tags applied to all resources
  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "Terragrunt"
  }
}

###############################################
# Remote State Backend (S3 + DynamoDB Locking)
###############################################
remote_state {
  backend = "s3"

  config = {
    bucket         = "assignment-state-s3-bucket"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "assignment-terraform-locks"
  }
}

###############################################
# Auto-generate AWS provider for Terraform
###############################################
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.region}"
}
EOF
}

###############################################
# Include root config in all child Terragrunt files
###############################################
inputs = {
  project     = local.project
  region      = local.region
  environment = local.environment
  common_tags = local.common_tags
}