resource "yandex_compute_instance" "bastion-elvm" {
  name = "${var.hostnames[0]}"
  platform_id = "${var.platform["v3"]}"
  zone        = "${var.zone_data["zone_a"]}"
  hostname = "${var.hostnames[0]}"

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
    subnet_id = yandex_vpc_subnet.subnet-internal-bastion.id                #subnet-internal-bastion
    security_group_ids = [yandex_vpc_default_security_group.bastion-sg.id]  #bastion-sg
    nat       = true
    ip_address = "10.130.0.254"
  }

depends_on = [yandex_vpc_default_security_group.bastion-sg]

  metadata = {
    user-data = "${file("./metadata/bastion.yml")}"
    serial-port-enable = 1
  }
 
  provisioner "local-exec" {
   command = " echo '[all:vars]' >> ./ansible/inventory"
 } 
  provisioner "local-exec" {
   command = " echo ' ansible_python_interpreter=/usr/bin/python3' >> ./ansible/inventory"
 } 
  provisioner "local-exec" {
   command = " echo ' ansible_ssh_user=${var.ssh_user[0]}' >> ./ansible/inventory"
 } 
  provisioner "local-exec" {
   command = " echo ' ansible_ssh_common_args=''-o StrictHostKeyChecking=no -o ProxyCommand=\"ssh -W %h:%p -q ${var.ssh_user[1]}@${self.network_interface.0.nat_ip_address}\"' >> ./ansible/inventory"
 }  
}

  resource "null_resource" "vm-hosts" {
  provisioner "local-exec" {
    command = "rm -rf ./ansible/inventory"
  }
}

output "bastion-elvm" {
  value = yandex_compute_instance.bastion-elvm.network_interface.0.nat_ip_address
}
