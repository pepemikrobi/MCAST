# Deploy vSwitch and its associated port-group

resource "vsphere_host_virtual_switch" "pod_vswitches" {

  for_each = var.portgroup_data

  name = format("POD%s_vSwitch%s", var.pod, replace(each.key, "X", var.pod)) 
  host_system_id      = data.vsphere_host.esxi_host.id
  mtu = 9000
  network_adapters = []
  active_nics = [] 
  standby_nics = []
}

resource "vsphere_host_port_group" "pod_portgroups" {

  for_each = var.portgroup_data

  name                = format("(%s) %s", replace(each.key, "X", var.pod), replace(each.value, "X", var.pod))
  host_system_id      = data.vsphere_host.esxi_host.id
  #virtual_switch_name = "vSwitch0"
  virtual_switch_name = format("POD%s_vSwitch%s", var.pod, replace(each.key, "X", var.pod)) 

  #vlan_id = tonumber(replace(each.key, "X", var.pod))
  vlan_id = each.key
  allow_promiscuous = true
  allow_forged_transmits = true
  allow_mac_changes = true

  depends_on = [
    vsphere_host_virtual_switch.pod_vswitches
  ]
}
