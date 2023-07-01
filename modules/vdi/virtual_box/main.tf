

terraform {
  required_providers {
    virtualbox = {
      source = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}


resource "random_string" "random" {
  length = 8
  special = false
  upper = false
}


# Needed to run this command before below "VBoxManage hostonlyif create"
resource "virtualbox_vm" "node" {
  name = "vdi-${random_string.random.result}"
  image = "https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20180903.0.0/providers/virtualbox.box"
  cpus = 2
  memory = "16000 mib"

  network_adapter {
    type = "bridged"
    host_interface = "Hyper-V Virtual Ethernet Adapter"
  }

}

