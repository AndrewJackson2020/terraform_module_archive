

variable "project" {
	type = "string"
	description = "GCP Project to deploy K8 cluster to"
}


variable "namespace" {
	type = "string"
	description = "Naming scheme for all resources created"
}



# GKE cluster
resource "google_container_cluster" "primary" {
  name = var.namespace
  project = var.project
  location = "us-central1"
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count = 1
  network = default
  subnetwork = "us-central1-a"
}


# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name = var.namespace
  project = var.project
  location = var.region
  cluster = google_container_cluster.primary.name
  node_count = 1
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    labels = {
      env = var.project
    }
    # preemptible  = true
    machine_type = "e2-medium"
    tags = ["gke-node", "${var.project}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

