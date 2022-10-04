// Environment
variable "locat" {
    default = "eastus"
}

variable "rg" {
    default = "staging"
}

variable env_tag {
    default = "staging"
}




//Network
variable "vnet" {
    default = "stagingNetwork"
}

variable "vnet_prefix" {
    default = "10.0.0.0/16"
}

variable "subnet" {
    default = "stagingSubnet"
}

variable "subnet_prefix" {
    default = "10.0.1.0/24"
}

variable "nic" {
    default = "stagingNic"
}



//Computing
variable "vm" {
    default = "vmlinux"
}