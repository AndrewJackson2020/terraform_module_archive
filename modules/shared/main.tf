

variable "project" {
	type = string
	description = "Project to deploy resources to"
}


resource "google_project_service" "project" {
  for_each = toset(["compute.googleapis.com", "iap.googleapis.com"])
  project = var.project
  service = each.value
  disable_on_destroy = false
}

