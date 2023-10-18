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
    security_group_ids = [yandex_vpc_security_group.internal-sg.id]    
    nat       = true
  }

  metadata = {
    user-data = "${file("./metadata/websrv.yml")}"
    serial-port-enable = 1
  } 

 provisioner "local-exec" {
   command = " echo '[${var.hostnames[1]}]' >> ./ansible/inventory"
 } 
 
 provisioner "local-exec" {
   command = " echo '${self.network_interface.0.ip_address}\n' >> ./ansible/inventory"
 }

 provisioner "file" {
   source      = "source/index.html"
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
   source      = "source/zabbix_agentd.conf"
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

  provisioner "file" {
   source      = "source/filebeat.yml"
   destination = "/tmp/filebeat.yml"
      
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
        "echo hello ${var.hostnames[1]}",       
        "sudo sed -i \"s|#numb|${var.hostnames[1]}|g\" /tmp/index_website.html",          
    #    "sudo cp /tmp/index_website.html /var/www/html/index.html",  
    #    "sudo cp /tmp/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf",
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
    security_group_ids = [yandex_vpc_security_group.internal-sg.id]    
    nat       = true
  }

  metadata = {
    user-data = "${file("./metadata/websrv.yml")}"
    serial-port-enable = 1
  } 

 provisioner "local-exec" {
   command = " echo '[${var.hostnames[2]}]' >> ./ansible/inventory"
 } 
 
 provisioner "local-exec" {
   command = " echo '${self.network_interface.0.ip_address}\n' >> ./ansible/inventory"
 }

 provisioner "file" {
   source      = "source/index.html"
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
   source      = "source/zabbix_agentd.conf"
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

  provisioner "file" {
   source      = "source/filebeat.yml"
   destination = "/tmp/filebeat.yml"
      
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
        "echo hello ${var.hostnames[2]}",       
        "sudo sed -i \"s|#numb|${var.hostnames[2]}|g\" /tmp/index_website.html",          
      #  "sudo cp /tmp/index_website.html /var/www/html/index.html",  
      #  "sudo cp /tmp/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf",        
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

output "ip_local_websrv-elvm-1" {
  value = yandex_compute_instance.websrv-elvm-1.network_interface.0.ip_address
}
output "srv-websrv-elvm-1" {
  value = yandex_compute_instance.websrv-elvm-1.network_interface.0.nat_ip_address
}

output "ip_local_websrv-elvm-2" {
  value = yandex_compute_instance.websrv-elvm-2.network_interface.0.ip_address
}
output "srv-websrv-elvm-2" {
  value = yandex_compute_instance.websrv-elvm-2.network_interface.0.nat_ip_address
}
