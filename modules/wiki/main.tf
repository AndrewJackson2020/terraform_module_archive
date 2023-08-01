

locals {
  region = "us-central1"
  zone = "${local.region}-a"
  port_name = "http"
  application_port = "443"
  pomerium_config = templatefile(
	"${path.module}/pomerium_config.yaml",
	{
	  wiki_url = "https://${var.domain_name}"
	  auth_url = "https://${var.auth_url}"
	}
  )
  startup_script = templatefile(
	"${path.module}/startup_script.sh", 
	{
		data_directory = "$${data_directory}",
		postgres_username = var.postgres_username,
		postgres_password = var.postgres_password	 
		pomerium_client_secret = var.pomerium_client_secret
		pomerium_client_id = var.pomerium_client_id
		pomerium_config = local.pomerium_config 
	}
  )
}


resource "google_compute_global_address" "wiki" {
  project = var.project
  address_type = "EXTERNAL"
  name = var.namespace
}


# TODO Secret manager is a more secure way to facilitate password and username to
#		containers. Problem is that the containers need to have custom entrypoint
# 		in order to use this service. Not worth it right now. Kubernetes might be
# 		a more legit way to accomplish this in a cloud agnostic way

# resource "google_secret_manager_secret" "pg_username" {
#   project = var.project
#   secret_id = "pg_username"
#   replication {
# 	automatic = true
#   }
# }
# 
# 
# resource "google_secret_manager_secret" "pg_password" {
#   project = var.project
#   secret_id = "pg_password"
#   replication {
# 	automatic = true
#   }
# }
# 
# 
# resource "google_secret_manager_secret_version" "pg_username" {
#   secret = google_secret_manager_secret.pg_username.id
#   secret_data = var.postgres_username
# }
# 
# 
# resource "google_secret_manager_secret_version" "pg_password" {
#   secret = google_secret_manager_secret.pg_password.id
#   secret_data = var.postgres_password
# }


resource "google_compute_disk" "wiki" {
  project = var.project
  name = var.namespace
  image = "projects/cos-cloud/global/images/cos-105-17412-156-4"
  size = 200
  zone = local.zone
}


resource "google_compute_instance_from_template" "wiki" {
  tags = [var.namespace]
  project = var.project
  name = var.namespace
  zone = local.zone
  source_instance_template = google_compute_instance_template.wiki.id
}


resource "google_compute_network" "wiki" {
  project = var.project
  name = var.namespace
  description = var.namespace
  auto_create_subnetworks = false
}


resource "google_compute_subnetwork" "wiki" {
  project = var.project
  name = var.namespace
  ip_cidr_range = "10.2.0.0/16"
  region = "us-central1"
  network = google_compute_network.wiki.id
}


resource "google_compute_instance_template" "wiki" {
  project = var.project
  name_prefix = "${var.namespace}-"
  machine_type = "e2-medium"
  region = local.region
  network_interface {
	# network = "default"
    network = var.namespace
	subnetwork = google_compute_subnetwork.wiki.self_link
    access_config {
      nat_ip = "${google_compute_global_address.wiki.address}"
    }
  }
  // boot disk
  disk {
    source = google_compute_disk.wiki.name
	auto_delete = false
  }
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email = google_service_account.wiki.email
	scopes = ["cloud-platform"]
  }
  metadata_startup_script = local.startup_script
}


resource "google_service_account" "wiki" {
  project = var.project
  account_id = "${var.namespace}-account"
  display_name = var.namespace
}


resource "google_compute_firewall" "iap_ssh_rule" {
  # network = "default"
  network = var.namespace
  project = var.project
  name = "${var.namespace}-ssh"
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  target_tags = [var.namespace]
  source_ranges = ["35.235.240.0/20"]
}


resource "google_compute_firewall" "health_check_rule" {
  # network = "default"
  network = var.namespace
  project = var.project
  name = "${var.namespace}-health"
  allow {
    protocol = "tcp"
    ports = [local.application_port]
  }
  target_tags = [var.namespace]
  source_ranges = ["0.0.0.0/0"]
}

