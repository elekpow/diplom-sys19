
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


## external bastion subnet
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-network-bastion.id    
    security_group_ids = [yandex_vpc_security_group.bastion_group_sg.id ]
	#ip_address = "172.16.16.254"	
    nat       = true  
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

output "network_interface0_nat_bastion" {
  value = yandex_compute_instance.bastion-elvm.network_interface.0.nat_ip_address
}

output "network_interface0_bastion" {
  value = yandex_compute_instance.bastion-elvm.network_interface.0.ip_address
}


#terraform apply -auto-approve