resource "yandex_compute_instance" "websrv-elvm-1" {
  name = "websrv-elvm-1"
  platform_id = "${var.platform["v3"]}"
  zone        = "${var.zone_data["zone_a"]}"
  hostname = "websrv-elvm-1"
  
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
    nat       = true
  }

  metadata = {
    user-data = "${file("./metadata.yml")}"
    serial-port-enable = 1
  } 
}


###########
resource "yandex_compute_instance" "websrv-elvm-2" {
  name = "websrv-elvm-2"
  platform_id = "${var.platform["v3"]}"
  zone        = "${var.zone_data["zone_b"]}"
  hostname = "websrv-elvm-2"

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
    nat       = true
  }

  metadata = {
    user-data = "${file("./metadata.yml")}"
    serial-port-enable = 1
  }
}



######### network
resource "yandex_vpc_network" "network-elvm" {
  name = "network-elvm"
}
resource "yandex_vpc_subnet" "subnet-a" {
  name           = "subnet-a"
  zone           = "${var.zone_data["zone_a"]}"
  network_id     = "${yandex_vpc_network.network-elvm.id}"
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet-b" {
  name           = "subnet-b"
  zone           = "${var.zone_data["zone_b"]}"
  network_id     = "${yandex_vpc_network.network-elvm.id}"
  v4_cidr_blocks = ["192.168.20.0/24"]
}



######### output
output "internal_ip_address_websrv-elvm-1" {
  value = yandex_compute_instance.websrv-elvm-1.network_interface.0.ip_address
}


output "external_ip_address_websrv-elvm-1" {
  value = yandex_compute_instance.websrv-elvm-1.network_interface.0.nat_ip_address
}


output "internal_ip_address_websrv-elvm-2" {
  value = yandex_compute_instance.websrv-elvm-2.network_interface.0.ip_address
}


output "external_ip_address_websrv-elvm-2" {
  value = yandex_compute_instance.websrv-elvm-2.network_interface.0.nat_ip_address
}
