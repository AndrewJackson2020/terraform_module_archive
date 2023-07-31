

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


resource "google_compute_target_https_proxy" "wiki" {
  project = var.project
  name = var.namespace
  url_map = google_compute_url_map.wiki.id
  ssl_certificates = [google_compute_managed_ssl_certificate.wiki.id]
}


resource "google_compute_managed_ssl_certificate" "wiki" {
  project = var.project
  name = var.namespace
  managed {
    domains = [
		var.domain_name, var.auth_url]
  }
}


resource "google_compute_global_forwarding_rule" "wiki" {
  project = var.project
  name = var.namespace
  ip_protocol = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range = local.application_port
  target = google_compute_target_https_proxy.wiki.id
  ip_address = google_compute_global_address.wiki.id
}


resource "google_compute_url_map" "wiki" {
  project = var.project
  name = var.namespace
  default_service = google_compute_backend_service.wiki.id
}


resource "google_compute_global_address" "wiki" {
  project = var.project
  address_type = "EXTERNAL"
  name = var.namespace
}


resource "google_compute_https_health_check" "wiki" {
  project = var.project
  name = var.namespace
  request_path = "/ping"
  port = local.application_port
  check_interval_sec = 1
  timeout_sec = 1
} 


resource "google_compute_backend_service" "wiki" {
  name = var.namespace
  project = var.project
  protocol = "HTTPS"
  port_name = local.port_name
  load_balancing_scheme = "EXTERNAL"
  health_checks = [google_compute_https_health_check.wiki.id]
  backend {
    group = google_compute_instance_group.wiki.id
    balancing_mode = "UTILIZATION"
    capacity_scaler = 1.0
  }
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


resource "google_compute_instance_group" "wiki" {
  project = var.project
  name = var.namespace
  description = var.namespace 
  instances = [
    google_compute_instance_from_template.wiki.self_link,
  ]
  named_port {
    name = local.port_name
    port = "443"
  }
  zone = local.zone
  # network = "projects/${var.project}/global/networks/default"
  network = google_compute_network.wiki.id 
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
      // Ephemeral public IP
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
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}

