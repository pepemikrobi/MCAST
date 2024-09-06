data "vsphere_datacenter" "datacenter" {
  name = "CSH"
}

data "vsphere_host" "esxi_host" {
  name          = var.esxi_hostname
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "pool" {
  name          = format("pod%s_mcast", var.pod)
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "datastore" {
  name          = var.esxi_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "dc1_net_mgmt" {
  name          = format("(11%02s) RSL_POD%s_DC1", var.pod, var.pod)
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "ports" {
  for_each = var.portgroup_data

  name = vsphere_host_port_group.pod_portgroups[each.key].name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}