variable "avi_controller_username" {
//  default = data.terraform_remote_state.phase1.outputs.vsphere-user
}
variable "avi_controller_password" {
//  default = data.terraform_remote_state.phase1.outputs.vsphere-password
  sensitive = true
}
variable "avi_cloud_name" {}
variable "avi_tenant" {}
variable "avi_version" {}

variable "tanzu_services_network_name" {}
variable "tanzu_services_network_cidr" {}

variable "tanzu_workloads_network_name" {}
variable "tanzu_workloads_network_cidr" {}

variable "dns_search_domain" {}
variable "dns_server" {}

