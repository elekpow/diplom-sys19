resource "yandex_compute_instance" "websrv-elvm-1" {
  name = "${var.hostnames[1]}"
  platform_id = "${var.platform["v3"]}"
  zone        = "${var.zone_data["zone_a"]}"
  hostname = "${var.hostnames[1]}"
  
  resources {
    core_fraction = 20 
    cores  = 2
    memory = 2
  }
 
  scheduling_policy {
    preemptible = true
  }
 
  boot_disk {
    initialize_params {
      image_id = "${var.images["debian_10"]}"
      type = "network-ssd"
      size = "10"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-a.id
    security_group_ids = [yandex_vpc_security_group.internal-sg.id, yandex_vpc_security_group.zabbix-elvm.id]
	ip_address = "172.16.121.10"
  }

  metadata = {
    user-data = "${file("./metadata/servers.yml")}"
    serial-port-enable = 1
  } 
 provisioner "local-exec" {
   command = "sed -i 's|#websrv-elvm-1|${self.network_interface.0.ip_address}|g' ./ansible/inventory"
 } 

}

resource "yandex_compute_instance" "websrv-elvm-2" {
  name = "${var.hostnames[2]}"
  platform_id = "${var.platform["v3"]}"
  zone        = "${var.zone_data["zone_b"]}"
  hostname = "${var.hostnames[2]}"
  
  resources {
    core_fraction = 20 
    cores  = 2
    memory = 2
  }
  
  scheduling_policy {
    preemptible = true
  }
  
  boot_disk {
    initialize_params {
      image_id = "${var.images["debian_10"]}"
      type = "network-ssd"
      size = "10"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-b.id
    security_group_ids = [yandex_vpc_security_group.internal-sg.id, yandex_vpc_security_group.zabbix-elvm.id]
	ip_address = "172.16.122.10"
    
  }

  metadata = {
    user-data = "${file("./metadata/servers.yml")}"
    serial-port-enable = 1
  } 

 provisioner "local-exec" {
   command = "sed -i 's|#websrv-elvm-2|${self.network_interface.0.ip_address}|g' ./ansible/inventory"
 } 

}

output "local_ip_websrv-elvm-1" {
  value = yandex_compute_instance.websrv-elvm-1.network_interface.0.ip_address
}

output "local_ip_websrv-elvm-2" {
  value = yandex_compute_instance.websrv-elvm-2.network_interface.0.ip_address
}
