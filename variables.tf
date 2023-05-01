variable "group" {
  description = "Name of the group"
  type        = string
}

variable "location" {
  description = "Location of the resource group"
  type        = map(any)
  default = {
    "name" = "East US"
    "code" = "eastus"
  }
}

variable "vm_cred" {
  description = "Credentials for the VMs"
  type        = map(any)
  default = {
    "user" = "azureuser"
    "pass" = "Admin1234"
  }
}
