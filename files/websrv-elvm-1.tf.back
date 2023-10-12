resource "yandex_compute_instance" "websrv-elvm-1" {
  name = "${var.hostnames[0]}"
  platform_id = "${var.platform["v3"]}"
  zone        = "${var.zone_data["zone_a"]}"
  hostname = "${var.hostnames[0]}"
  
  resources {
    core_fraction = 20 
    cores  = 2
    memory = 2
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
    user-data = "${file("./metadata.yml")}"
    serial-port-enable = 1
  } 

  connection {
     type = "ssh"
     user = "${var.ssh_user_1}"
     host = self.network_interface.0.nat_ip_address
     agent = true
  }



  provisioner "local-exec" {
   command = " echo '[${var.hostnames[0]}]' >> inventory"
 } 
  provisioner "local-exec" {
   command = " echo '${self.network_interface.0.ip_address}\n' >> inventory"
}

## ANSIBLE first install
  provisioner "local-exec" {
    command = "sleep 30; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory ./ansible/install.yml"
  }

#ssh -i ~/.ssh/id_ed25519 -J bastion@158.160.106.140 igor@172.16.11.33




 # provisioner "file" {
 #   source      = "source/index.html"
 #   destination = "/tmp/index_website.html"
 # }

#  provisioner "remote-exec" {
#    inline = [
#         "echo hello",
#         "sudo apt update",
#         "sudo apt install nginx -y",       
#         "sudo cp /tmp/index_website.html /var/www/html/index.html",
#    ]
# }

}



output "local_ip_websrv-elvm-1" {
  value = yandex_compute_instance.websrv-elvm-1.network_interface.0.ip_address
}


output "websrv-elvm-1" {
  value = yandex_compute_instance.websrv-elvm-1.network_interface.0.nat_ip_address
}