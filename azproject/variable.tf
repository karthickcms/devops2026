variable "azlocation" {
  default = "centralindia"
}
variable "rg01" {
  default = "kartrg"
}
variable "vnet" {
  type    = string
  default = "myvnet01"
}
variable "vnet-add" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}
variable "mysubnets" {
  type = map(object({
    address_prefixes = list(string)
  }))
  default = {
    "app-subnet" = { address_prefixes = ["10.0.1.0/24"] }
    "db-subnet"  = { address_prefixes = ["10.0.2.0/24"] }
  }
}
variable "nsg1" {
  default = "nsg01"
}
variable "nsg2" {
  default = "nsg02"
}
variable "nic1" {
  default = "VM1-nic1"
}
variable "prv_ip_alloc" {
  default = "Dynamic"
}
variable "vm1" {
  default = "app01"
}
variable "vm2" {
  default = "app02"
}
variable "vmsize" {
  default = "Standard_FX2ms_v2"
}
variable "username" {
  default = "azureuser"
}
variable "adminpass" {
  default   = "P@$$w0rd1234!"
  sensitive = true
}
