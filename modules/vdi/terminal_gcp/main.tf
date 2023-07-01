

locals {
  zone = "us-central1-a"
}


data "google_project" "project" {
  project_id = var.project 
}


variable "project" {
  type = string
}


resource "google_service_account" "default" {
  
  project = var.project
  account_id = "service-account-id"
  display_name = "Service Account"
}



resource "google_compute_disk" "foobar" {
  project = var.project
  name = "existing-disk"
  image = "debian-11" 
  size = 200
  type = "pd-ssd"
  zone = local.zone
}


resource "google_compute_resource_policy" "hourly" {

  name = "policy"
  project = var.project
  region = "us-central1"
  description = "Start and stop instances"
  instance_schedule_policy {
    
    vm_stop_schedule {
      schedule = "0 0 * * *"
    }
    time_zone = "US/Central"
  }
}


resource "google_project_iam_member" "gce-default-account-iam" {
  project = var.project
  role = "projects/${var.project}/roles/${google_project_iam_custom_role.my-custom-role.role_id}"
  member = "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com"

}


resource "google_project_iam_custom_role" "my-custom-role" {
  project = var.project
  role_id = "myCustomRole"
  title = "My Custom Role"
  description = "A description"
  permissions = ["compute.instances.stop"]

}


resource "google_compute_instance_template" "instance_template" {
  
  project = var.project
  name_prefix = "instance-template-"
  machine_type = "e2-standard-2"
  region = "us-central1"
  tags = ["iap-tunnel"]
  
  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  // boot disk
  disk {
    source = google_compute_disk.foobar.name
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
  depends_on = [google_project_iam_member.gce-default-account-iam]
}
