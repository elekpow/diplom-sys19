
resource "yandex_compute_instance" "bastion-elvm" {
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
      image_id = "${var.images["debian_10"]}"
      type = "network-ssd"
      size = "10"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-internal-bastion.id    
    security_group_ids = [yandex_vpc_default_security_group.internal-bastion-sg.id]
    nat       = true
  }

  metadata = {
    user-data = "${file("./metadata-bastion.yml")}"
    serial-port-enable = 1
  }


   provisioner "local-exec" {
   command = " echo '\n ansible_ssh_common_args='-J ${var.ssh_user_2}@${self.network_interface.0.nat_ip_address}'\n' >> hosts.ini"
 }

  provisioner "local-exec" {
   command = " echo '[bastion]' >> hosts.ini"
 }   
  provisioner "local-exec" {
   command = " echo '${self.network_interface.0.nat_ip_address}\n' >> hosts.ini"
 }
  

  
  
  
}


###### null_resource_inventory
  resource "null_resource" "vm-hosts" {
  provisioner "local-exec" {
    command = "rm -rf ./hosts.ini; cp ./templ_hosts.ini ./hosts.ini"
  }
}