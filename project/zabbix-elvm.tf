resource "yandex_compute_instance" "zabbix-elvm" {
  name = "${var.hostnames[3]}"
  platform_id = "${var.platform["v3"]}"
  zone        = "${var.zone_data["zone_a"]}"
  hostname = "${var.hostnames[3]}"
  
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
      image_id = "${var.images["debian_11"]}"
      type = "network-ssd"
      size = "10"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-a.id
    security_group_ids = [yandex_vpc_security_group.internal-sg.id, yandex_vpc_security_group.zabbix-elvm.id]    
    nat       = true
	ip_address = "172.16.121.254"
  }

  metadata = {
    user-data = "${file("./metadata/servers.yml")}"
    serial-port-enable = 1
  } 

 provisioner "local-exec" {
   command = "sed -i 's|#zabbix-elvm|${self.network_interface.0.ip_address}|g' ./ansible/inventory"
 } 
 
  provisioner "local-exec" {
   command = "sed -i 's|#zabbix|${self.network_interface.0.nat_ip_address}|g' ./ansible/roles/nginx/files/index.html"
 } 
 
 
}

output "local_ip_zabbix-elvm" {
  value = yandex_compute_instance.zabbix-elvm.network_interface.0.ip_address
}
output "host_zabbix-elvm" {
  value = yandex_compute_instance.zabbix-elvm.network_interface.0.nat_ip_address
}
