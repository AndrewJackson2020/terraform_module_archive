

locals {
	required_apis = [
		"compute.googleapis.com", "iap.googleapis.com", "container.googleapis.com"]
}

variable "project" {
	type = string
	description = "Project to deploy resources to"
}


resource "google_project_service" "project" {
  for_each = toset(local.required_apis)
  project = var.project
  service = each.value
  disable_on_destroy = false
}

