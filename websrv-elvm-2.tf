resource "yandex_compute_instance" "websrv-elvm-2" {
  name = "${var.hostnames[1]}"
  platform_id = "${var.platform["v3"]}"
  zone        = "${var.zone_data["zone_b"]}"
  hostname = "${var.hostnames[1]}"

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
    subnet_id = yandex_vpc_subnet.subnet-b.id
#    subnet_id = yandex_vpc_subnet.internal-bastion-sg.id
 #   nat       = true
  }

  metadata = {
    user-data = "${file("./metadata.yml")}"
    serial-port-enable = 1
  }
 
  provisioner "local-exec" {
   command = " echo '[${var.hostnames[1]}]' >> hosts.ini"
 }   
  provisioner "local-exec" {
   command = " echo '${self.network_interface.0.ip_address}\n' >> hosts.ini"
 }


#  connection {
#     type = "ssh"
#     user = "${var.ssh_user}"
#     host = self.network_interface.0.nat_ip_address
#     agent = true
#  }

#  provisioner "file" {
#    source      = "source/index.html"
#    destination = "/tmp/index_website.html"
#  }

#  provisioner "remote-exec" {
#    inline = [
#         "echo hello",
#         "sudo apt update",
#         "sudo apt install nginx -y",
#         "sudo cp /tmp/index_website.html /var/www/html/index.html",
#    ]
# }

}

