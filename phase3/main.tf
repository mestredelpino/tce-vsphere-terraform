# ---------------------------------------------------------------------------------------------------------------------
# SET UP PROVIDERS AND REQUIRED VERSIONS
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0"
}

terraform {
  required_providers {
    vsphere = "~> 2.0.2"
    local = "~> 1.4"
  }
}

provider "vsphere" {
  user                 = data.terraform_remote_state.phase1.outputs.vsphere-user
  password             = data.terraform_remote_state.phase1.outputs.vsphere-password
  vsphere_server       = data.terraform_remote_state.phase1.outputs.vsphere-server
  allow_unverified_ssl = true
}

# ---------------------------------------------------------------------------------------------------------------------
# SET THE DATA VALUES
# ---------------------------------------------------------------------------------------------------------------------

data "terraform_remote_state" "phase1" {
  backend = "local"
  config = {
    path = "../phase1/terraform.tfstate"
  }
}

data "terraform_remote_state" "phase2" {
  backend = "local"
  config = {
    path = "../phase2/terraform.tfstate"
  }
}

data "vsphere_datacenter" "dc" {
  name = data.terraform_remote_state.phase1.outputs.vsphere-datacenter
}

data "vsphere_network" "network" {
  name          = data.terraform_remote_state.phase2.outputs.tanzu-workloads-network-name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = data.terraform_remote_state.phase1.outputs.vsphere-datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "resource_pool" {
  name          = data.terraform_remote_state.phase1.outputs.vsphere-resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "ubuntu_template" {
  name          = data.terraform_remote_state.phase1.outputs.focal-ova-name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "local_file" "default-ssl-cert-base64" {
  filename = "./default-ssl-cert-base64.txt"
  depends_on = [null_resource.get-certificate]
}
data "local_file" "vsphere-datastore-url" {
  filename = local.datastore-url-file
}

locals {
  mgmt_cluster_control_plane_ip         = cidrhost(data.terraform_remote_state.phase2.outputs.tanzu-workloads-network-cidr,17)
  tkg_services_cluster_control_plane_ip = cidrhost(data.terraform_remote_state.phase2.outputs.tanzu-workloads-network-cidr,18)
  dev_cluster_control_plane_ip          = cidrhost(data.terraform_remote_state.phase2.outputs.tanzu-workloads-network-cidr,19)
  datastore-url-file                    = "./datastore_url.txt"
}

# EXTRACT SSL CERTIFICATE (Comment out to get the certificate through terraform running on powershell)
//resource "null_resource" "get-certificate" {
//  provisioner "local-exec" {
//    command = <<EOT
//$terraform_state = (Get-Content '..\phase2\terraform.tfstate')
//$terraform_state = $terraform_state | ConvertFrom-JSON
//$certificate_base64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(($terraform_state.outputs.cert.value.certificate.certificate).trim()))
//$certificate_base64 | set-content default-ssl-cert-base64.txt -nonewline
//EOT
//    interpreter = ["C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe", "-Command"]
//    when = create
//  }
//}

# EXTRACT DATASTORE URL FOR KUBERNETES STORAGE CLASS (Comment out to get the datastore url through terraform running on powershell)
//resource "null_resource" "get-datastore-url" {
//  provisioner "local-exec" {
//    command = <<EOT
//Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -Scope User -ParticipateInCEIP $false -Confirm:$false
//Connect-VIServer -Server "${data.terraform_remote_state.phase1.outputs.vsphere-server}" -User "${data.terraform_remote_state.phase1.outputs.vsphere-user}" -Password "${data.terraform_remote_state.phase1.outputs.vsphere-password}"
//(Get-Datastore "${data.terraform_remote_state.phase1.outputs.vsphere-datastore}").ExtensionData.info.url  | set-content "${local.datastore-url-file}" -nonewline
//EOT
//    interpreter = ["C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe", "-Command"]
//    when = create
//  }
//}

resource "vsphere_folder" "vm_folder" {
  path          = var.vm_folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# DEFINE THE FILES THAT WILL BE PROVISIONED TO THE VM

resource "local_file" "vsphere_storage_class" {
  content = templatefile("vsphere-storageclass.yml.tpl", {
    datastore_url = data.local_file.vsphere-datastore-url.content
  })
  filename        = "vsphere-storageclass.yml"
  file_permission = "0644"
}

resource "local_file" "tkg_configuration_file" {
  content = templatefile("tkg-cluster.yml.tpl", {
    vcenter-server          = data.terraform_remote_state.phase1.outputs.vsphere-server
    vcenter-user            = data.terraform_remote_state.phase1.outputs.vsphere-user
    vcenter-password        = data.terraform_remote_state.phase1.outputs.vsphere-password
    vcenter-datacenter      = data.terraform_remote_state.phase1.outputs.vsphere-datacenter
    vcenter-datastore       = data.terraform_remote_state.phase1.outputs.vsphere-datastore
    tanzu-workloads-network = data.terraform_remote_state.phase2.outputs.tanzu-workloads-network-name
    vcenter-resource_pool   = data.terraform_remote_state.phase1.outputs.vsphere-resource_pool
    vcenter-vm_folder       = var.vm_folder
    control_plane_ip        = local.mgmt_cluster_control_plane_ip
    avi-controller-ip       = data.terraform_remote_state.phase1.outputs.avi-controller-ip
    avi-username            = data.terraform_remote_state.phase2.outputs.avi-username
    avi-password            = data.terraform_remote_state.phase2.outputs.avi-password
    avi-data-network-name   = data.terraform_remote_state.phase2.outputs.tanzu-services-network-name
    avi-data-network-cidr   = data.terraform_remote_state.phase2.outputs.tanzu-services-network-cidr
    avi-cloud-name          = data.terraform_remote_state.phase2.outputs.avi-cloud
    avi-se-group            = data.terraform_remote_state.phase2.outputs.avi-se-group
    avi-ssl-certificate     = data.local_file.default-ssl-cert-base64.content
  })
  filename        = "tkg-cluster.yml"
  file_permission = "0644"
}

# Generate additional configuration file.
resource "local_file" "env_file" {
  content = templatefile("env.tpl", {
    control_plane_endpoint_mgmt         = local.mgmt_cluster_control_plane_ip
    control_plane_endpoint_tkg_services = local.tkg_services_cluster_control_plane_ip
    control_plane_endpoint_dev          = local.dev_cluster_control_plane_ip
    tanzu_cli                           = var.tanzu-cli
  })
  filename        = "env"
  file_permission = "0644"
}

# Use the jumpbox to access TKG from the outside.
resource "vsphere_virtual_machine" "jumpbox" {
  name                       = "jumpbox"
  resource_pool_id           = data.vsphere_resource_pool.resource_pool.id
  datastore_id               = data.vsphere_datastore.datastore.id
  wait_for_guest_net_timeout = -1
  wait_for_guest_ip_timeout  = 2
  num_cpus                   = 2
  memory                     = 6000
  guest_id                   = "ubuntu64Guest"
  folder                     = vsphere_folder.vm_folder.path

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "disk0"
    thin_provisioned = false // true
    size             = 20
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.ubuntu_template.id
  }
  cdrom {
    client_device = true
  }
  vapp {
    properties = {
      "instance-id" = "tce-jumpbox"
      "hostname"    = "tce-jumpbox"
      "public-keys" = file("~/.ssh/id_rsa.pub")
    }
  }

  connection {
    host        = vsphere_virtual_machine.jumpbox.default_ip_address
    timeout     = "30s"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
  }

//  provisioner "file" {
//    # Copy TKG configuration file.
//    source      = "${var.kubectl-vmware-cli}"
//    destination = "/home/ubuntu/kubectl-cli.gz"
//  }

  provisioner "file" {
    # Copy TKG configuration file.
    source      = "tkg-cluster.yml"
    destination = "/home/ubuntu/tkg-cluster.yml"
  }
  provisioner "file" {
    # Copy additional configuration file.
    source      = "env"
    destination = "/home/ubuntu/.env"
  }

  provisioner "file" {
    # Copy additional configuration file.
    source      = "./vsphere-storageclass.yml"
    destination = "/home/ubuntu/tanzu/vsphere-storageclass.yml"
  }

  provisioner "file" {
    # Copy kubectl.
    source      = "${var.tanzu-cli}"
    destination = "/home/ubuntu/${var.tanzu-cli}"
  }

  provisioner "file" {
    # Copy install scripts.
    source      = "./setup-jumpbox-tce.sh"
    destination = "/home/ubuntu/setup-jumpbox-tce.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${vsphere_virtual_machine.jumpbox.default_ip_address} jumpbox | sudo tee -a /etc/hosts",
      "chmod +x /home/ubuntu/setup-jumpbox-tce.sh",
      "sh /home/ubuntu/setup-jumpbox-tce.sh",
      "rm /home/ubuntu/setup-jumpbox-tce.sh",
    ]
    on_failure = continue
  }
}





