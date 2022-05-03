variable "vm_folder" {
  type    = string
}

variable "tanzu-cli" {
  description = "The path to your Tanzu CLI file (.tar.gz)"
  type = string
}

variable "kubectl_version" {
  description = "The version of kubectl to install in the Jumpbox"
  type = string
}


variable "ssh_key-pub-file" {
  description = "The path to a file containing the public SSH key for the jumpbox"
  default = null
}

variable "ssh_key-file" {
  description = "The path to a file containing the private SSH key for the jumpbox"
  default = null
}

variable "ssh_key-pub" {
  description = "The public SSH key for the jumpbox"
  default = ""
}

variable "ssh_key" {
  description = "The private SSH key for the jumpbox"
  default = ""
}

//variable "kubectl-vmware-cli" {
//  description = "The VMware's official kubectl cli (not required for TCE)"
//  default = ""
//  type = string
//}



