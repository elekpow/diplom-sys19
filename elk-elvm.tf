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
    user-data = "${file("./metadata/websrv.yml")}"
    serial-port-enable = 1
  } 

 provisioner "local-exec" {
   command = " echo '[${var.hostnames[4]}]' >> ./ansible/inventory"
 } 
 
 provisioner "local-exec" {
   command = " echo '${self.network_interface.0.ip_address}\n' >> ./ansible/inventory"
 }

 provisioner "file" {
   source      = "ansible/roles/nginx/files/index.html"
   destination = "/tmp/index_website.html"
  
    connection {
     type = "ssh"
     user = "${var.ssh_user[0]}"
     host = self.network_interface.0.ip_address
     agent = true
     
     bastion_user = "${var.ssh_user[1]}"
     bastion_host = yandex_compute_instance.bastion-elvm.network_interface.0.nat_ip_address     
  } 
 } 
 
  provisioner "file" {
   source      = "ansible/roles/zabbix/files/zabbix_agentd.conf"
   destination = "/tmp/zabbix_agentd.conf"
      
     connection {
     type = "ssh"
     user = "${var.ssh_user[0]}"
     host = self.network_interface.0.ip_address
     agent = true
     
     bastion_user = "${var.ssh_user[1]}"
     bastion_host = yandex_compute_instance.bastion-elvm.network_interface.0.nat_ip_address     
  } 
 }   
 
  provisioner "remote-exec" {
   inline = [
        "echo hello ${var.hostnames[4]}",       
        "sudo sed -i \"s|#numb|${var.hostnames[4]}|g\" /tmp/index_website.html",          
   ]
 
  connection {
     type = "ssh"
     user = "${var.ssh_user[0]}"
     host = self.network_interface.0.ip_address
     agent = true
     
     bastion_user = "${var.ssh_user[1]}"
     bastion_host = yandex_compute_instance.bastion-elvm.network_interface.0.nat_ip_address     
  }
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
    user-data = "${file("./metadata/websrv.yml")}"
    serial-port-enable = 1
  } 

 provisioner "local-exec" {
   command = " echo '[${var.hostnames[5]}]' >> ./ansible/inventory"
 } 
 
 provisioner "local-exec" {
   command = " echo '${self.network_interface.0.ip_address}\n' >> ./ansible/inventory"
 }

 provisioner "file" {
   source      = "ansible/roles/nginx/files/index.html"
   destination = "/tmp/index_website.html"
 
    connection {
     type = "ssh"
     user = "${var.ssh_user[0]}"
     host = self.network_interface.0.ip_address
     agent = true
     
     bastion_user = "${var.ssh_user[1]}"
     bastion_host = yandex_compute_instance.bastion-elvm.network_interface.0.nat_ip_address     
  } 
 } 
 
  provisioner "file" {
   source      = "ansible/roles/zabbix/files/zabbix_agentd.conf"
   destination = "/tmp/zabbix_agentd.conf"
 
    connection {
     type = "ssh"
     user = "${var.ssh_user[0]}"
     host = self.network_interface.0.ip_address
     agent = true
     
     bastion_user = "${var.ssh_user[1]}"
     bastion_host = yandex_compute_instance.bastion-elvm.network_interface.0.nat_ip_address     
  } 
 } 

 
 provisioner "remote-exec" {
   inline = [
        "echo hello ${var.hostnames[5]}",       
        "sudo sed -i \"s|#numb|${var.hostnames[5]}|g\" /tmp/index_website.html",          
   ]
 
  connection {
     type = "ssh"
     user = "${var.ssh_user[0]}"
     host = self.network_interface.0.ip_address
     agent = true
     
     bastion_user = "${var.ssh_user[1]}"
     bastion_host = yandex_compute_instance.bastion-elvm.network_interface.0.nat_ip_address     
  }
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
