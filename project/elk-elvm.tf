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
      type = "network-hdd"
      size = "10"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-a.id
    security_group_ids = [yandex_vpc_security_group.internal-sg.id, yandex_vpc_security_group.elastic-elvm-sg.id]    
	ip_address = "172.16.121.20"
  }

  metadata = {
    user-data = "${file("./metadata/servers.yml")}"
    serial-port-enable = 1
  } 

 provisioner "local-exec" {
   command = "sed -i 's|#elastic-elvm|elastic-elvm.ru-central1.internal|g' ./ansible/inventory"
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
      type = "network-hdd"
      size = "10"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-a.id
    security_group_ids = [yandex_vpc_security_group.internal-sg.id,yandex_vpc_security_group.kibana-elvm.id]    
    nat       = true
	ip_address = "172.16.121.30"
  }

  metadata = {
    user-data = "${file("./metadata/servers.yml")}"
    serial-port-enable = 1
  } 

 provisioner "local-exec" {
   command = "sed -i 's|#kibana-elvm|kibana-elvm.ru-central1.internal|g' ./ansible/inventory"
 } 

 
 provisioner "local-exec" {
   command = "sed -i 's|#kibana|${self.network_interface.0.nat_ip_address}|g' ./ansible/roles/nginx/files/index.html"
 } 
 
 
 
}


output "kibana-elvm" {
  value = yandex_compute_instance.kibana-elvm.network_interface.0.nat_ip_address
}
