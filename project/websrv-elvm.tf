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
      type = "network-hdd"
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
   command = "sed -i 's|#websrv-elvm-1|websrv-elvm-1.ru-central1.internal|g' ./ansible/inventory"
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
      type = "network-hdd"
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
   command = "sed -i 's|#websrv-elvm-2|websrv-elvm-2.ru-central1.internal|g' ./ansible/inventory"
 } 

}

