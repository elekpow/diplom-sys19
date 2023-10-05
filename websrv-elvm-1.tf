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
