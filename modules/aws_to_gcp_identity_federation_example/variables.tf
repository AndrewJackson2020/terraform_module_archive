

variable "environment" {
  description = "Software environment to deploy resources"
  type = string
}


variable "AWS_ACCESS_KEY_ID" {
  
  description = "AWS key ID credential. Secret value that should be set via environment variable."
  type = string
}


variable "AWS_SECRET_ACCESS_KEY" {

  description = "AWS secret key. Secret value that should be set via environment variable."
  type = string
}


variable "AWS_REGION" {
  description = "AWS region to deploy VM"
  type = string
}


variable "gcp_project" {
  
  description = "GCP project to deploy resources"
  type = string
  default = "skilful-alpha-358420"
}



locals {

  gcp_project_environment_mapper = {prod = "skilful-alpha-358420", dev = "skilful-alpha-358420", test = "primeval-door-374216"}
  gcp_project = local.gcp_project_environment_mapper[var.environment]

}
