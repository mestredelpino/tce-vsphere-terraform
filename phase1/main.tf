# ---------------------------------------------------------------------------------------------------------------------
# SET THE TERRAFORM PROVIDERS AND REQUIRED VERSIONS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.14"
}

provider "vsphere" {
  user                 = var.vsphere-user
  password             = var.vsphere-password
  vsphere_server       = var.vsphere-server
  allow_unverified_ssl = true
}

# ---------------------------------------------------------------------------------------------------------------------
# SET THE DATA VALUES
# ---------------------------------------------------------------------------------------------------------------------


# SET VSPHERE PREDEFINED DATA OBJECTS
data "vsphere_datacenter" "dc" {
  name = var.vsphere-datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere-datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vsphere-resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

# FETCH THE ESXI HOST AND THE NETWORK FROM PREVIOUS STAGES AND ADD THEM AS DATA OBJECTS

data "vsphere_host" "host" {
  name          = var.vsphere-host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "vm-services" {
  name          = var.vsphere-network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "avi-mgmt" {
  name          = var.avi-mgmt-network-name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THREE VIRTUAL MACHINES FROM OVA TEMPLATES
# ---------------------------------------------------------------------------------------------------------------------

resource "vsphere_folder" "templates-folder" {
  path          = var.vsphere-vm-template-folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_folder" "avi-folder" {
  path          = var.vsphere-vm-avi-folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "focal-cloudserver" {
  name                       = var.focal-ova-name
  resource_pool_id           = data.vsphere_resource_pool.pool.id
  datastore_id               = data.vsphere_datastore.datastore.id
  host_system_id             = data.vsphere_host.host.id
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  datacenter_id              = data.vsphere_datacenter.dc.id
  folder                     = vsphere_folder.templates-folder.path
  network_interface {
    network_id = data.vsphere_network.vm-services.id
  }
  ovf_deploy {
    remote_ovf_url = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.ova"
    ovf_network_map = {"VM Network": data.vsphere_network.vm-services.id
    }
  }
  cdrom {
    client_device = true
  }
}

resource "vsphere_virtual_machine" "avi-controller" {
  name                       = var.avi-vm-name
  resource_pool_id           = data.vsphere_resource_pool.pool.id
  datastore_id               = data.vsphere_datastore.datastore.id
  host_system_id             = data.vsphere_host.host.id
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  datacenter_id              = data.vsphere_datacenter.dc.id
  num_cpus                   = 8
  memory                     = 24000
//  folder                     =
  network_interface {
    network_id = data.vsphere_network.avi-mgmt.id
  }
  ovf_deploy {
    ovf_network_map = {"VM Network": data.vsphere_network.avi-mgmt.id
    }
    local_ovf_path = var.local-ova-path-avi
    remote_ovf_url = var.remote-ova-url-avi
  }
  cdrom {
    client_device = true
  }
    vapp {
    properties = {
      "mgmt-ip"    = var.avi-controller-ip
      "mgmt-mask"  = cidrnetmask(var.avi-mgmt-network-cidr)
      "default-gw" = var.avi-mgmt-network-gw
    }
  }
}

resource "vsphere_virtual_machine" "tanzu-template-vm" {
  name                       = var.tanzu-ova-name
  resource_pool_id           = data.vsphere_resource_pool.pool.id
  datastore_id               = data.vsphere_datastore.datastore.id
  host_system_id             = data.vsphere_host.host.id
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  datacenter_id              = data.vsphere_datacenter.dc.id
  num_cpus                   = 2
  memory                     = 2048
  folder                     = vsphere_folder.templates-folder.path
  network_interface {
    network_id = data.vsphere_network.vm-services.id
  }
  ovf_deploy {
    ovf_network_map = {"nic0": data.vsphere_network.vm-services.id
    }
    local_ovf_path = var.local-ova-path-tanzu
    remote_ovf_url = var.remote-ova-url-tanzu
  }
  cdrom {
    client_device = true
  }
}