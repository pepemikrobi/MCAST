variable "vcsa_hostname" {
}

variable "esxi_hostname" {
}

variable "esxi_datastore" {
}

variable "vcsa_username" {
}

variable "vcsa_password" {
}

variable "pod" {
}

variable "mcast_router_data" {
  type = map(object({
    name = string
    index = number
    serial_port = string
    gi2 = string
    gi3 = string
    gi4 = optional (string)
  }))
}

variable "mcast_switch_data" {
  type = map(object({
    name = string
    index = number
    serial_port = string
    eth1 = string
    eth2 = string
    eth3 = string
    eth4 = string
  }))
}

variable "mcast_server_data" {
  type = map(object({
    name = string
    index = number
    ens224 = string
    ens224_ip = string
  }))
}

variable "portgroup_data" {
  type = map(string)
}
