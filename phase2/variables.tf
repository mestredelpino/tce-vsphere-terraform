variable "avi-username" {
//  default = data.terraform_remote_state.phase1.outputs.vsphere-user
}
variable "avi-password" {
//  default = data.terraform_remote_state.phase1.outputs.vsphere-password
  sensitive = true
}
variable "avi-cloud-name" {}
variable "avi-tenant" {}
variable "avi-version" {}

variable "tanzu-services-network-name" {}
variable "tanzu-services-network-cidr" {}

variable "tanzu-workloads-network-name" {}
variable "tanzu-workloads-network-cidr" {}

variable "dns-search_domain" {}
variable "dns-server_list" {}

