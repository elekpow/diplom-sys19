resource "yandex_compute_instance" "zabbix-elvm" {
  name = "${var.hostnames[2]}"
  platform_id = "${var.platform["v3"]}"
  zone        = "${var.zone_data["zone_a"]}"
  hostname = "${var.hostnames[2]}"
  
  resources {
    core_fraction = 20 
    cores  = 2
    memory = 2
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
    security_group_ids = [yandex_vpc_security_group.internal-sg.id]    
    nat       = true
  }

  metadata = {
    user-data = "${file("./metadata/zabbix.yml")}"
    serial-port-enable = 1
  } 



 provisioner "local-exec" {
   command = " echo '[${var.hostnames[2]}]' >> inventory"
 } 
 
 provisioner "local-exec" {
   command = " echo '${self.network_interface.0.ip_address}\n' >> inventory"
 }

 provisioner "file" {
   source      = "source/zabbix.conf.php"
   destination = "/tmp/zabbix.conf.php"
 
   connection {
     type = "ssh"
     user = "${var.ssh_user_1}"
     host = self.network_interface.0.ip_address
     agent = true
     
     bastion_user = "${var.ssh_user_2}"
     bastion_host = yandex_compute_instance.bastion-elvm.network_interface.0.nat_ip_address     
  }
 
 }
  
 
 # provisioner "remote-exec" {
   # inline = [
        # "echo hello", 
       # "sudo apt install nginx -y",        
        # "sudo apt install postgresql -y", 
       # "wget https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian11_all.deb",
        # "sudo dpkg -i zabbix-release_6.4-1+debian11_all.deb",
        # "sudo apt update",
        # "sudo cp /tmp/index_website.html /var/www/html/index.html",
   # ]
 
  # connection {
     # type = "ssh"
     # user = "${var.ssh_user_1}"
     # host = self.network_interface.0.ip_address
     # agent = true
     
     # bastion_user = "${var.ssh_user_2}"
     # bastion_host = yandex_compute_instance.bastion-elvm.network_interface.0.nat_ip_address     
  # }

 # }
}




output "local_ip_zabbix-elvm" {
  value = yandex_compute_instance.zabbix-elvm.network_interface.0.ip_address
}
output "zabbix-elvm" {
  value = yandex_compute_instance.zabbix-elvm.network_interface.0.nat_ip_address
}
