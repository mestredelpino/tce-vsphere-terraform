# ---------------------------------------------------------------------------------------------------------------------
# SET THE TERRAFORM PROVIDERS AND REQUIRED VERSIONS
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.14"
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

# ---------------------------------------------------------------------------------------------------------------------
# SET THE DATA VALUES
# ---------------------------------------------------------------------------------------------------------------------


# SET VSPHERE PREDEFINED DATA OBJECTS
data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

# FETCH THE ESXI HOST AND THE NETWORK FROM PREVIOUS STAGES AND ADD THEM AS DATA OBJECTS

data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "vm-services" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "avi-mgmt" {
  name          = var.avi_mgmt_network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THREE VIRTUAL MACHINES FROM OVA TEMPLATES
# ---------------------------------------------------------------------------------------------------------------------

resource "vsphere_folder" "templates-folder" {
  path          = var.vsphere_vm_template_folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_folder" "avi-folder" {
  path          = var.vsphere_vm_avi_folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "focal-cloudserver" {
  name                       = var.focal_ova_name
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
  name                       = var.avi_vm_name
  resource_pool_id           = data.vsphere_resource_pool.pool.id
  datastore_id               = data.vsphere_datastore.datastore.id
  host_system_id             = data.vsphere_host.host.id
  datacenter_id              = data.vsphere_datacenter.dc.id
  num_cpus                   = var.avi_controller_cpus
  memory                     = var.avi_controller_memory
  folder                     = vsphere_folder.avi-folder.path
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  network_interface {
    network_id = data.vsphere_network.avi-mgmt.id
  }
  ovf_deploy {
    ovf_network_map = {"VM Network": data.vsphere_network.avi-mgmt.id
    }
    local_ovf_path = var.local_ova_path_avi
    remote_ovf_url = var.remote_ova_url_avi
  }
  cdrom {
    client_device = true
  }
    vapp {
    properties = {
      "mgmt-ip"    = var.avi_controller_ip
      "mgmt-mask"  = cidrnetmask(var.avi_mgmt_network_cidr)
      "default-gw" = var.avi_mgmt_network_gw
    }
  }
}

resource "vsphere_virtual_machine" "tanzu-template-vm" {
  name                       = var.tanzu_ova_name
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
    local_ovf_path = var.local_ova_path_tanzu
    remote_ovf_url = var.remote_ova_url_tanzu
  }
  cdrom {
    client_device = true
  }
}