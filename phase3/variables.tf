variable "vm_folder" {
  type    = string
}

variable "tanzu_cli" {
  description = "The path to your Tanzu CLI file (.tar.gz)"
  type = string
}

variable "kubectl_version" {
  description = "The version of kubectl to install in the Jumpbox"
  type = string
}


variable "ssh_key_pub_file" {
  description = "The path to a file containing the public SSH key for the jumpbox"
  default = null
}

variable "tanzu_ova_os" {
  description = "The Operating System of the Tanzu OVA (photon or ubuntu)"
  default = null
}

variable "ssh_key_file" {
  description = "The path to a file containing the private SSH key for the jumpbox"
  default = null
}

//variable "kubectl-vmware-cli" {
//  description = "The VMware's official kubectl cli (not required for TCE)"
//  default = ""
//  type = string
//}



