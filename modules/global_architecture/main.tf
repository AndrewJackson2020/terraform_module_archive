

# Creates random string. Used to ensure bucket has globally unique name
resource "random_string" "random" {
  length = 8
  lower = true
  upper = false
  special = false
}


# Creates GCP bucket to store terraform state data
resource "google_storage_bucket" "auto-expire" {
  
  project = var.project_id
  name = "terraform_state_${random_string.random.result}" 
  location = "US"
  force_destroy = true

  public_access_prevention = "enforced"

}


# Creates GCP source repository to store terraform live infrastructure modules
resource "google_sourcerepo_repository" "terraform_live_infrastructure" {
  
  project = var.project_id
  name = "terraform_live_infrastructure"
  depends_on = [google_project_service.project]
}


# Creates GCP source repository to store terraform modules
resource "google_sourcerepo_repository" "terraform_module_archive" {
  
  project = var.project_id
  name = "terraform_module_archive"
  depends_on = [google_project_service.project]
  
}



# Creates GCP source repository to store terraform modules
resource "google_sourcerepo_repository" "machine_learning_for_trading" {
  
  project = var.project_id
  name = "machine_learning_for_trading"
  depends_on = [google_project_service.project]
  
}


# Activates required API
resource "google_project_service" "project" {

  project = var.project_id
  service = "sourcerepo.googleapis.com"  

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}
