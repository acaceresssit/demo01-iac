variable location {
  default = "East US"
}

##Resource grup Vaibles###
variable resource_group_name {
  default = "demo-iac-2022"
}

##AKS Variables #
variable cluster_name {
  default = "aksdemo1"
}

variable agent_count {
  default = 1
}

variable dns_prefix {
  default = "aksdemo"
}

variable admin_username {
  default = "aksdemo"
}

variable "output_directory" {
  type    = string
  default = "./output"
}

variable "kubeconfig_filename" {
  description = "Nombre del kubeconfig."
  type        = string
  default     = "aks_config"
}