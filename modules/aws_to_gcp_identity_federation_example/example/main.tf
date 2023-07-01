


variable "AWS_ACCESS_KEY_ID" {
  type = string
}


variable "AWS_SECRET_ACCESS_KEY" {
  type = string
}


variable "AWS_REGION" {
  type = string
}


module "servers" {
  source = "../"
  environment = "dev"
  AWS_REGION = var.AWS_REGION
  AWS_SECRET_ACCESS_KEY = var.AWS_SECRET_ACCESS_KEY
  AWS_ACCESS_KEY_ID = var.AWS_ACCESS_KEY_ID
  gcp_project = "ml4t-dev"
}
