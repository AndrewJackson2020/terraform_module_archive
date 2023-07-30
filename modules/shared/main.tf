

variable "project" {
	type = string
	description = "Project to deploy resources to"
}


resource "google_project_service" "project" {
  project = var.project
  service = "compute.googleapis.com"
  disable_on_destroy = false
}

