resource "yandex_vpc_network" "network-elvm" { 
  name = "network-elvm"
}

resource "yandex_vpc_subnet" "subnet-internal-bastion" { 
  name           = "subnet-internal-bastion"
  description    = "myNetwork-subnet description" 
  v4_cidr_blocks = ["172.16.120.0/24"]
  zone           = "${var.zone_data["zone_a"]}"
  network_id     = "${yandex_vpc_network.network-elvm.id}" 
  depends_on = [yandex_vpc_network.network-elvm] 
  
}

resource "yandex_vpc_subnet" "subnet-a" { 
  name           = "subnet-a"
  description    = "myNetwork-subnet-a description" 
  v4_cidr_blocks = ["172.16.121.0/24"]
  zone           = "${var.zone_data["zone_a"]}"
  network_id     = "${yandex_vpc_network.network-elvm.id}" 
  depends_on = [yandex_vpc_network.network-elvm] 
  
}
