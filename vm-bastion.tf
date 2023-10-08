
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
      image_id = "${var.images["ubuntu_nat_18"]}"
      type = "network-ssd"
      size = "10"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-external-bastion.id    
    security_group_ids = [yandex_vpc_default_security_group.secure-bastion-sg.id]
    nat       = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-internal-bastion.id    
    security_group_ids = [yandex_vpc_default_security_group.internal-bastion-sg.id]
  #  nat       = true
  }
  





  metadata = {
    user-data = "${file("./metadata-bastion.yml")}"
    serial-port-enable = 1
  }

  
 ################################
 
  provisioner "local-exec" {
   command = " echo '[all:vars]' >> inventory"
 } 
  provisioner "local-exec" {
   command = " echo ' ansible_python_interpreter=/usr/bin/python3' >> inventory"
 } 
  provisioner "local-exec" {
   command = " echo ' ansible_ssh_user=igor' >> inventory"
 } 
  provisioner "local-exec" {
   command = " echo ' ansible_ssh_common_args=''-o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -W %h:%p -q ${var.ssh_user_2}@${self.network_interface.0.nat_ip_address}\"' >> inventory"
 } 
 
  
}


###### null_resource_inventory
  resource "null_resource" "vm-hosts" {
  provisioner "local-exec" {
    command = "rm -rf ./inventory"
  }
}


######### output
output "internal_ip_address_bastion-elvm" {
  value = yandex_compute_instance.bastion-elvm.network_interface.0.ip_address
}

output "internal_ip_address_bastion-elvm1" {
  value = yandex_compute_instance.bastion-elvm.network_interface.1.ip_address
}



output "external_ip_address_bastion-elvm" {
  value = yandex_compute_instance.bastion-elvm.network_interface.0.nat_ip_address
}
