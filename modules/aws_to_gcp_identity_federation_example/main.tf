

# GCP provider configuration
provider "google-beta" {

  project = var.gcp_project
  region = "us-central1"

}


# Binds BQ Owner service account to identity federation
resource "google_service_account_iam_binding" "admin-account-iam" {
  
  service_account_id = google_service_account.bqowner.name
  role = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.gh_pool.name}/*" 
  ]
}


# Assigns permisisons to service account
resource "google_project_iam_binding" "example" {

  project = var.gcp_project
  role = "roles/bigquery.dataEditor"

  members = [
    "serviceAccount:${google_service_account.bqowner.email}",
  ]
}


# Creates service account for identity federation to impersonate
resource "google_service_account" "bqowner" {

  provider = google-beta
  account_id = "bqowner-${var.environment}"

}


# Creates BigQuery dataset
resource "google_bigquery_dataset" "dataset" {
  
  provider = google-beta
  dataset_id = "example_dataset_${var.environment}"
  friendly_name = "test"
  description = "This is a test description"
  location = "US"

  labels = {
    env = "default"
  }

}


# Creates Bigquery table
resource "google_bigquery_table" "default" {

  provider = google-beta

  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "bar"
  deletion_protection = false
  time_partitioning {
    type = "DAY"
  }

  labels = {
    env = "default"
  }

  schema = <<EOF
[
  {
    "name": "permalink",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The Permalink"
  },
  {
    "name": "state",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "State where the head office is located"
  }
]
EOF

}


# Creates random string
# Used in identity pool to facilitate testing since they don't delete immediately
resource "random_string" "random" {
  length = 8
  lower = true
  upper = false
  special = false
}


# Creates identity pool
resource "google_iam_workload_identity_pool" "gh_pool" {
  project = var.gcp_project
  provider = google-beta
  workload_identity_pool_id = "gh-pool-${var.environment}-${random_string.random.result}"
}


# Creates identity provider bound to AWS account
resource "google_iam_workload_identity_pool_provider" "example" {
  
  project = var.gcp_project
  workload_identity_pool_id = google_iam_workload_identity_pool.gh_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "example-prvdr-${var.environment}"
  aws {
    account_id = "032954141183"
  }

}


# Injects runtime generated values into template shell script for identity federation config download
data "template_file" "whatever" {
  template = "${file("${path.module}/scripts/download_identity_config.sh")}"
  vars = {
    google_iam_workload_identity_pool_provider_name = google_iam_workload_identity_pool_provider.example.name,
    google_service_account_email = google_service_account.bqowner.email
  }
}


# Download identity federation config file
resource "null_resource" "example_1" {

  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    command = data.template_file.whatever.rendered
  }

}


# Injects runtime generated values into template shell script for VM setup
data "template_file" "vm_setup" {
  template = "${file("${path.module}/scripts/setup_vm.sh")}"
  vars = {
    aws_access_key_id = var.AWS_ACCESS_KEY_ID,
    aws_secret_access_key = var.AWS_SECRET_ACCESS_KEY,
    region = var.AWS_REGION
  }
}


# Configures AWS instance. Also runs VM setup script
resource "aws_instance" "web" {

  ami = "ami-0ceecbb0f30a902a6"
  instance_type = "t3.micro"
  key_name = aws_key_pair.generated_key.key_name

  tags = {
    Name = "HelloWorld-${var.environment}"
  }
  security_groups = ["launch-wizard-1"]

  provisioner "file" {
    content = "${data.template_file.vm_setup.rendered}"
    destination = "/tmp/setup_vm.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup_vm.sh",
      "sudo /tmp/setup_vm.sh",
      "rm /tmp/setup_vm.sh", 
    ]
  }

  # Login to the ec2-user with the aws key.
  connection {
    type = "ssh"
    user = "ec2-user"
    password = ""
    private_key = tls_private_key.example.private_key_pem
    host = self.public_ip
  }
  
}


# Creates private key for AWS VM SSH run
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


# Upload SSH key to AWS
resource "aws_key_pair" "generated_key" {
  key_name = "key"
  public_key = tls_private_key.example.public_key_openssh
}


# Create S3 bucket as intermediary to store identity federation configuration file 
resource "aws_s3_bucket" "b" {

  bucket = "gcp-to-aws-identity-federation"

  tags = {
    Name = "gcp-to-aws-identity-federation"
    Environment = "Dev"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = "aws s3 mv workload_identity_pool_config.json s3://gcp-to-aws-identity-federation/workload_identity_pool_config.json"
  }
  
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    when    = destroy
    command = "aws s3 rm s3://gcp-to-aws-identity-federation --recursive"
  }

  depends_on = [null_resource.example_1]

}
