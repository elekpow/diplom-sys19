resource "yandex_compute_instance" "elastic-elvm" {
  name = "${var.hostnames[4]}"
  platform_id = "${var.platform["v3"]}"
  zone        = "${var.zone_data["zone_a"]}"
  hostname = "${var.hostnames[4]}"
  
  resources {
    core_fraction = 20 
    cores  = 2
    memory = 8
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
    security_group_ids = [yandex_vpc_security_group.internal-sg.id]    
    nat       = true
  }

  metadata = {
    user-data = "${file("./metadata/servers.yml")}"
    serial-port-enable = 1
  } 

 provisioner "local-exec" {
   command = "sed -i 's|#elastic-elvm|${self.network_interface.0.ip_address}|g' ./ansible/inventory"
 } 

}

resource "yandex_compute_instance" "kibana-elvm" {
  name = "${var.hostnames[5]}"
  platform_id = "${var.platform["v3"]}"
  zone        = "${var.zone_data["zone_a"]}"
  hostname = "${var.hostnames[5]}"
  
  resources {
    core_fraction = 20 
    cores  = 2
    memory = 8
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
    security_group_ids = [yandex_vpc_security_group.internal-sg.id]    
    nat       = true
  }

  metadata = {
    user-data = "${file("./metadata/servers.yml")}"
    serial-port-enable = 1
  } 

 provisioner "local-exec" {
   command = "sed -i 's|#kibana-elvm|${self.network_interface.0.ip_address}|g' ./ansible/inventory"
 } 

 
}

output "local_ip_elastic-elvm" {
  value = yandex_compute_instance.elastic-elvm.network_interface.0.ip_address
}
# output "srv-elastic-elvm-1" {
  # value = yandex_compute_instance.elastic-elvm.network_interface.0.nat_ip_address
# }

output "local_ip_kibana-elvm" {
  value = yandex_compute_instance.kibana-elvm.network_interface.0.ip_address
}
output "kibana-elvm" {
  value = yandex_compute_instance.kibana-elvm.network_interface.0.nat_ip_address
}
