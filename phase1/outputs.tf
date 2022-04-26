output "focal-ova-name" {
  value = vsphere_virtual_machine.focal-cloudserver.name
}

output "vsphere-password" {
  value = var.vsphere-password
  sensitive = true
}
output "vsphere-user" {
  value = var.vsphere-user
  sensitive = true
}
output "vsphere-server" {
  value = var.vsphere-server
}

output "vsphere-datacenter" {
  value = var.vsphere-datacenter
}

output "vsphere-datastore" {
  value = var.vsphere-datastore
}

output "vsphere-network-name" {
  value = var.vsphere-network
}

output "vsphere-resource_pool" {
  value = var.vsphere-resource_pool
}

output "avi-controller-ip" {
  value = var.avi-controller-ip
}

output "avi-mgmt-network-name" {
  value = data.vsphere_network.avi-mgmt.name
}

output "avi-mgmt-network-cidr" {
  value = var.avi-mgmt-network-cidr
}

