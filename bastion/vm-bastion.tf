resource "yandex_compute_instance" "bastion-elvm" {
  name = "bastion-elvm"
  platform_id = "${var.platform["v3"]}"
  zone        = "${var.zone_data["zone_a"]}"
  hostname = "bastion-elvm"

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
    subnet_id = yandex_vpc_subnet.my-external-subnet.id
#    security_group_ids = [yandex_vpc_security_group.secure-bastion-sg.id]
    nat       = true
  }


  metadata = {
    user-data = "${file("./metadata.yml")}"
    serial-port-enable = 1
  }
}



######### network
#resource "yandex_vpc_network" "network-elvm" {
#  name = "network-elvm"
#}
#resource "yandex_vpc_subnet" "subnet-a" {
#  name           = "subnet-a"
#  zone           = "${var.zone_data["zone_a"]}"
#  network_id     = "${yandex_vpc_network.network-elvm.id}"
#  v4_cidr_blocks = ["192.168.10.0/24"]
#}





######### output
output "internal_ip_address_bastion-elvm" {
  value = yandex_compute_instance.bastion-elvm.network_interface.0.ip_address
}


output "external_ip_address_bastion-elvm" {
  value = yandex_compute_instance.bastion-elvm.network_interface.0.nat_ip_address
}
