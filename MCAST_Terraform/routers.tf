# Deploy Cisco 8000v virtual router and add serial port using provisioner

data "vsphere_virtual_machine" "template" {
  name          = format("pod%s_mcast_8000v_1795a", var.pod)
  datacenter_id = data.vsphere_datacenter.datacenter.id
}


resource "vsphere_virtual_machine" "mcast_router" {

  for_each = var.mcast_router_data

  name                       = format("POD%s_%s", var.pod, each.key)
  resource_pool_id           = data.vsphere_resource_pool.pool.id
  datastore_id               = data.vsphere_datastore.datastore.id
  host_system_id             = data.vsphere_host.esxi_host.id
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  num_cpus                   = 1
  memory                     = 4096
  #firmware                   = "efi"
  guest_id                   = "other3xLinux64Guest"
  #boot_delay                 = 2000
  
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
  }

  disk {
    label            = "disk0"
    size             = 8
    thin_provisioned = true
  }

  cdrom {
    client_device = true
  }

  cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path = format("ISO/%s.iso", replace(each.value["name"], "X", var.pod))
  }

  # Gi1
  network_interface {
    network_id   = data.vsphere_network.dc1_net_mgmt.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
    use_static_mac = true
    mac_address  = format("02:ca:fe:0%s:%s:01", var.pod, each.value["index"])
  }

  # Gi2
  network_interface {
    network_id   = data.vsphere_network.ports[each.value["gi2"]].id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
    use_static_mac = true
    mac_address  = format("02:ca:fe:0%s:%s:02", var.pod, each.value["index"])
  }

  # Gi3
  network_interface {
    network_id   = data.vsphere_network.ports[each.value["gi3"]].id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
    use_static_mac = true
    mac_address  = format("02:ca:fe:0%s:%s:03", var.pod, each.value["index"])
  }

  # Gi4
  network_interface {
    network_id   = data.vsphere_network.ports[each.value["gi4"]].id 
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
    use_static_mac = true
    mac_address  = format("02:ca:fe:0%s:%s:04", var.pod, each.value["index"])
  }
}

resource "null_resource" "router_setup_console" {
    for_each = var.mcast_router_data

    triggers = {
      trigger = "${vsphere_virtual_machine.mcast_router[each.key].uuid}"
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


