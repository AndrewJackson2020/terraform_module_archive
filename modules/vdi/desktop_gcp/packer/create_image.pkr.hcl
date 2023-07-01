

variable "project" {

  type = string
  
}


packer {
  required_plugins {
    googlecompute = {
      version = ">= 1.0.0"
      source = "github.com/hashicorp/googlecompute"
    }
  }
}


source "googlecompute" "basic-example" {
  project_id = var.project
  source_image_family = "debian-10"
  image_family = "vdi"
  ssh_username = "packer"
  zone = "us-central1-a"
}


build {

  sources = ["sources.googlecompute.basic-example"]

  provisioner "shell" {
    script = "./setup_vm.sh"
  }

  provisioner "file" {
    source = ".ssh"
    destination = "/tmp"
  }

  provisioner "shell" {
    script = "./setup_vm_2.sh"
  }
}
