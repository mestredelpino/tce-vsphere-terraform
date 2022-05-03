# INFRA VARIABLES

variable "vsphere_user" {
  description = "Your vSphere username"
  type = string
}

variable "vsphere_password" {
  description = "Your vSphere password"
  type = string
  sensitive = true
}

variable "vsphere_server" {
  description = "Your vCenter server"
  type = string
}

variable "vsphere_datacenter" {
  description = "The name of your vSphere datacenter"
  type = string
}

variable "vsphere_datastore" {
  description = "The name of your vSphere datastore"
  type = string
}

variable "vsphere_resource_pool" {
  description = "The name of your vSphere resource pool"
  default = "Resources"
  type = string
}

variable "vsphere_host" {
  description = "The IP address of the ESXi host where the VM will be created"
  type = string
 validation {
    condition = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",var.vsphere_host))
    error_message = "Invalid IP address provided."
  }
}

variable "vsphere_network" {
  description = "The network the template VMs will use"
  type = string
}

variable "avi_mgmt_network_name" {
  description = "The network to be used by the tanzu workloads"
  type = string
}

variable "vsphere_vm_folder" {
  description = "The vSphere directory the VMs will be placed into"
  type = string
}

variable "focalOVA_name" {
  description = "The name of the ubuntu-server OVA that will be deployed (used to create a jumpbox)"
  default = "focalOVA"
}

variable "avi_controller_ip" {
  description = "The desired static IP address of the AVI controller"
  type = string
 validation {
    condition = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",var.avi_controller_ip))
    error_message = "Invalid IP address provided."
  }
}
variable "avi_mgmt_network_cidr" {
  description = "The CIDR of the AVI management network"
}
variable "avi_mgmt_network_gw" {
  default = "The IP address of the gateway for the AVI management network"
}


variable "avi_vm_name" {
  default = "avi-controller"
}

variable "avi_controller_cpus" {
  description = "Number of vCPUs to assign to your AVI controller"
  default = 8
}

variable "avi_controller_memory" {
  description = "The amount of memory (in MB) to assign to your AVI controller"
  default = 24000
}


variable "focal_ova_name" {}
variable "tanzu_ova_name" {}


variable "vsphere_vm_template_folder" {
  default = ""
}
variable "vsphere_vm_avi_folder" {
  default = ""
}

variable "remote_ova_url_avi" {
  description = "The URL of the location where the AVI OVA is located"
  default = null
}

variable "remote_ova_url_tanzu" {
  description = "The URL of the location where the Tanzu OVA is located"
  default = null
}

variable "local_ova_path_tanzu" {
  description = "The (local) path to the Tanzu OVA"
  default = null
}
variable "local_ova_path_avi" {
  description = "The (local) path to the AVI OVA"
  default = null
}