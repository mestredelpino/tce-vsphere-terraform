# INFRA VARIABLES

variable "vsphere-user" {
  description = "Your vSphere username"
  type = string
}

variable "vsphere-password" {
  description = "Your vSphere password"
  type = string
  sensitive = true
}

variable "vsphere-server" {
  description = "Your vCenter server"
  type = string
}

variable "vsphere-datacenter" {
  description = "The name of your vSphere datacenter"
  type = string
}

variable "vsphere-datastore" {
  description = "The name of your vSphere datastore"
  type = string
}

variable "vsphere-resource_pool" {
  description = "The name of your vSphere resource pool"
  default = "Resources"
  type = string
}

variable "vsphere-host" {
  description = "The IP address of the ESXi host where the VM will be created"
  type = string
 validation {
    condition = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",var.vsphere-host))
    error_message = "Invalid IP address provided."
  }
}

variable "vsphere-network" {
  description = "The network the template VMs will use"
  type = string
}

variable "avi-mgmt-network-name" {
  description = "The network to be used by the tanzu workloads"
  type = string
}

variable "vsphere-vm-folder" {
  description = "The vSphere directory the VMs will be placed into"
  type = string
}

variable "focalOVA_name" {
  description = "The name of the ubuntu-server OVA that will be deployed (used to create a jumpbox)"
  default = "focalOVA"
}

variable "avi-controller-ip" {
  description = "The desired static IP address of the AVI controller"
  type = string
 validation {
    condition = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",var.avi-controller-ip))
    error_message = "Invalid IP address provided."
  }
}
variable "avi-mgmt-network-cidr" {
  description = "The CIDR of the AVI management network"
}
variable "avi-mgmt-network-gw" {
  default = "The IP address of the gateway for the AVI management network"
}


variable "avi-vm-name" {
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


variable "focal-ova-name" {}
variable "tanzu-ova-name" {}


variable "vsphere-vm-template-folder" {
  default = ""
}
variable "vsphere-vm-avi-folder" {
  default = ""
}

variable "remote-ova-url-avi" {
  description = "The URL of the location where the AVI OVA is located"
  default = null
}

variable "remote-ova-url-tanzu" {
  description = "The URL of the location where the Tanzu OVA is located"
  default = null
}

variable "local-ova-path-tanzu" {
  description = "The (local) path to the Tanzu OVA"
  default = null
}
variable "local-ova-path-avi" {
  description = "The (local) path to the AVI OVA"
  default = null
}