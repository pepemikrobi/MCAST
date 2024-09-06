vcsa_hostname = "vcenter.sdn.lab"
vcsa_username = "podX-admin@hector.lan"
esxi_hostname = "podX-esx1.sdn.lab"
esxi_datastore = "podX-esx1-ds1"

pod = X

mcast_router_data = {

   R1 = {
    name = "PODX_R1"
    index = 11
    serial_port = "2X01"
    gi2 = "4095"
    gi3 = "4095"
    gi4 = "4095"
  }

  R2 = {
    name = "PODX_R2"
    index = 12
    serial_port = "2X02"
    gi2 = "4095"
    gi3 = "2002"
    gi4 = "4095"
  }

  R3 = {
    name = "PODX_R3"
    index = 13
    serial_port = "2X03"
    gi2 = "4095"
    gi3 = "4095"
    gi4 = "2103"
  }

  R4 = {
    name = "PODX_R4"
    index = 14
    serial_port = "2X04"
    gi2 = "4095"
    gi3 = "2004"
    gi4 = "2104"
  }

  R5 = {
    name = "PODX_R5"
    index = 15
    serial_port = "2X05"
    gi2 = "4095"
    gi3 = "4095"
    gi4 = "4095"
  } 

  R6 = {
    name = "PODX_R6"
    index = 16
    serial_port = "2X06"
    gi2 = "4095"
    gi3 = "2006"
    gi4 = "4095"    
  }

  R7 = {
    name = "PODX_R7"
    index = 17
    serial_port = "2X07"
    gi2 = "4095"
    gi3 = "4095"
    gi4 = "4095"
  }  

  R8 = {
    name = "PODX_R8"
    index = 18
    serial_port = "2X08"
    gi2 = "4095"
    gi3 = "4095"
    gi4 = "4095"
  }  

   R9 = {
    name = "PODX_R9"
    index = 19
    serial_port = "2X09"
    gi2 = "4095"
    gi3 = "2009"
    gi4 = "4095"
  } 
}

mcast_switch_data = {

  SW1 = {
    name = "PODX_SW1"
    index = 20
    serial_port = "2X00"
    eth1 = "2103"
    eth2 = "2104"
    eth3 = "2113"
    eth4 = "2114"
  }
}

mcast_server_data = {

  Source1 = {
    name = "podX-source1"
    index = 21
    ens224 = "2006"
    ens224_ip = "172.16.1.121"
  }

  Receiver1 = {
    name = "podX-receiver1"
    index = 31
    ens224 = "2004"
    ens224_ip = "172.16.10.131"
  }

  Receiver2 = {
    name = "podX-receiver2"
    index = 32
    ens224 = "2002"
    ens224_ip = "172.16.20.132"
  }

  Receiver3= {
    name = "podX-receiver3"
    index = 33
    ens224 = "2113"
    ens224_ip = "172.16.30.133"
  }  

  Receiver4= {
    name = "podX-receiver4"
    index = 34
    ens224 = "2114"
    ens224_ip = "172.16.30.134"
  }  

  Receiver5= {
    name = "podX-receiver5"
    index = 35
    ens224 = "2009"
    ens224_ip = "172.16.50.135"
  }    
}

portgroup_data = {
  "4095" = "PODX_Routers"
  "2002" = "PODX_R2_Receiver2"
  "2004" = "PODX_R4_Receiver1"
  "2006" = "PODX_R6_Source1"
  "2009" = "PODX_R9_Receiver5"  
  "2103" = "PODX_R3_SW1"
  "2104" = "PODX_R4_SW1"
  "2113" = "PODX_SW1_Receiver3"
  "2114" = "PODX_SW1_Receiver4"
 }

