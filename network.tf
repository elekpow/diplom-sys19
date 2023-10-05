
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



