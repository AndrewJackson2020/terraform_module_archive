

variable "project" {
	type = string
	description = "GCP Project to deploy K8 cluster to"
}


variable "region" {
	type = string
}


variable "namespace" {
	type = string
	description = "Naming scheme for all resources created"
}


# GKE cluster
resource "google_container_cluster" "wiki" {
  name = var.namespace
  project = var.project
  location = var.region
  node_config {
    disk_type = "pd-standard"
  }
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count = 1
  network = google_compute_network.wiki.id
  subnetwork = google_compute_subnetwork.wiki.id
}


resource "google_service_account" "wiki" {
  project = var.project
  account_id = "${var.namespace}-k8"
  display_name = "Service Account"
}


# Separately Managed Node Pool
resource "google_container_node_pool" "wiki" {
  name = var.namespace
  project = var.project
  location = var.region
  cluster = google_container_cluster.wiki.name
  node_count = 1
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    # preemptible  = true
    machine_type = "e2-micro"
	service_account = google_service_account.wiki.email
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
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

