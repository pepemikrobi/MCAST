# Deploy Cisco Nexus 9300v virtual machine and add serial port using provisioner

data "vsphere_virtual_machine" "switch_template" {
  #name          = format("pod%s_n9300v_10.2.5_scsi_thin", var.pod)
  name = "podX_n9300v_10.2.5_scsi_thin"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}


resource "vsphere_virtual_machine" "mcast_switch" {

  for_each = var.mcast_switch_data

  name                       = format("POD%s_%s", var.pod, each.key)
  resource_pool_id           = data.vsphere_resource_pool.pool.id
  datastore_id               = data.vsphere_datastore.datastore.id
  host_system_id             = data.vsphere_host.esxi_host.id
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  num_cpus                   = 4
  memory                     = 8192
  firmware                   = "efi"
  guest_id                   = "otherGuest64"
  boot_delay                 = 2000
  
  clone {
    template_uuid = "${data.vsphere_virtual_machine.switch_template.id}"
  }

  disk {
    label            = "disk0"
    size             = 10
    thin_provisioned = true
  }

  extra_config = {
    "efi.serialconsole.enabled" = "TRUE"
  }

  # mgmt0
  network_interface {
    network_id   = data.vsphere_network.dc1_net_mgmt.id
    adapter_type = data.vsphere_virtual_machine.switch_template.network_interface_types[0]
    use_static_mac = true
    mac_address  = format("02:ca:fe:0%s:%s:09", var.pod, each.value["index"])
  }

  # Eth1/1
  network_interface {
    network_id   = data.vsphere_network.ports[each.value["eth1"]].id
    adapter_type = data.vsphere_virtual_machine.switch_template.network_interface_types[0]
    use_static_mac = true
    mac_address  = format("02:ca:fe:0%s:%s:11", var.pod, each.value["index"])
  }

  # Eth1/2
  network_interface {
    network_id   = data.vsphere_network.ports[each.value["eth2"]].id
    adapter_type = data.vsphere_virtual_machine.switch_template.network_interface_types[0]
    use_static_mac = true
    mac_address  = format("02:ca:fe:0%s:%s:12", var.pod, each.value["index"])
  }

  # Eth1/3
  network_interface {
    network_id   = data.vsphere_network.ports[each.value["eth3"]].id
    adapter_type = data.vsphere_virtual_machine.switch_template.network_interface_types[0]
    use_static_mac = true
    mac_address  = format("02:ca:fe:0%s:%s:13", var.pod, each.value["index"])
  }

  # Eth1/4
  network_interface {
    network_id   = data.vsphere_network.ports[each.value["eth4"]].id
    adapter_type = data.vsphere_virtual_machine.switch_template.network_interface_types[0]
    use_static_mac = true
    mac_address  = format("02:ca:fe:0%s:%s:14", var.pod, each.value["index"])
  }

}

resource "null_resource" "dc1_setup_console" {
    for_each = var.mcast_switch_data

    triggers = {
      trigger = "${vsphere_virtual_machine.mcast_switch[each.key].uuid}"
    }
    provisioner "local-exec" {

        #credits
        #http://access-console-port-virtual-machine.blogspot.com/2013/07/add-serial-port-to-vm-through-gui-or.html
        #https://kevsoft.net/2019/04/26/multi-line-powershell-in-terraform.html
        #https://markgossa.blogspot.com/2019/04/run-powershell-from-terraform.html?m=1
        command = <<EOPS

          Function New-SerialPort {
             Param(
               [string]$vmName,
               [string]$prt
             )
            $dev = New-Object VMware.Vim.VirtualDeviceConfigSpec
            $dev.operation = "add"
            $dev.device = New-Object VMware.Vim.VirtualSerialPort
            $dev.device.key = -1
            $dev.device.backing = New-Object VMware.Vim.VirtualSerialPortURIBackingInfo
            $dev.device.backing.direction = "server"
            $dev.device.backing.serviceURI = "telnet://:$prt"
            $dev.device.connectable = New-Object VMware.Vim.VirtualDeviceConnectInfo
            $dev.device.connectable.connected = $true
            $dev.device.connectable.StartConnected = $true
            $dev.device.yieldOnPoll = $true

            $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
            $spec.DeviceChange += $dev

            $vm = Get-VM -Name $vmName
            Stop-VM $VM -Confirm:$False
            $vm.ExtensionData.ReconfigVM($spec)
            Start-VM $VM -Confirm:$False
          }

          Connect-VIServer -Server ${var.vcsa_hostname} -User ${var.vcsa_username} -Password ${var.vcsa_password}
          New-SerialPort ${replace(each.value["name"], "X", var.pod)} ${replace(each.value["serial_port"], "X", var.pod)}
          Disconnect-VIServer -Confirm:$false
        EOPS
        interpreter = ["pwsh", "-Command"]
   }
}

