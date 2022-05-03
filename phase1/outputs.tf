output "focal-ova-name" {
  value = vsphere_virtual_machine.focal-cloudserver.name
}

output "vsphere-password" {
  value = var.vsphere_password
  sensitive = true
}
output "vsphere-user" {
  value = var.vsphere_user
  sensitive = true
}
output "vsphere-server" {
  value = var.vsphere_server
}

output "vsphere-datacenter" {
  value = var.vsphere_datacenter
}

output "vsphere-datastore" {
  value = var.vsphere_datastore
}

output "vsphere-network-name" {
  value = var.vsphere_network
}

output "vsphere-resource_pool" {
  value = var.vsphere_resource_pool
}

output "avi-controller-ip" {
  value = var.avi_controller_ip
}

output "avi-mgmt-network-name" {
  value = data.vsphere_network.avi-mgmt.name
}

output "avi-mgmt-network-cidr" {
  value = var.avi_mgmt_network_cidr
}
