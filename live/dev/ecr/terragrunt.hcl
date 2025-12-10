include "root" {
  path = find_in_parent_folders()
  expose = true
}

terraform {
  source = "../../../modules/ecr//"
}

inputs = {
  repo_name = "assignment-app"
  tags = include.root.locals.common_tags
}