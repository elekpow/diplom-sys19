
#network 2
resource "yandex_vpc_network" "network-external" { 
  name = "external-bastion"
}

resource "yandex_vpc_subnet" "subnet-external-bastion" { 
  name           = "subnet-external-bastion"
  description    = "myNetwork-subnet description" 
  v4_cidr_blocks = ["172.16.17.0/28"]
  zone           = "${var.zone_data["zone_a"]}"
  network_id     = "${yandex_vpc_network.network-external.id}" 
  depends_on = [yandex_vpc_network.network-external] 
  
}

resource "yandex_vpc_subnet" "subnet-internal-bastion" { 
  name           = "subnet-internal-bastion"
  description    = "myNetwork-subnet description" 
  v4_cidr_blocks = ["172.16.16.0/28"]
  zone           = "${var.zone_data["zone_a"]}"
  network_id     = "${yandex_vpc_network.network-external.id}" 
  depends_on = [yandex_vpc_network.network-external] 
  
}

###security_group####

resource "yandex_vpc_default_security_group" "bastion-sg" {
 # name        = "bastion-sg"
  description = "Description for security group"
  network_id  = "${yandex_vpc_network.network-external.id}"

  ingress {
    protocol       = "TCP"
    description    = "Rule description 1"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "ANY"
    v4_cidr_blocks= ["0.0.0.0/0"]
  }
    
}

resource "yandex_vpc_default_security_group" "internal-bastion-sg" {
 # name        = "bastion-sg"
  description = "Description for security group"
  network_id  = "${yandex_vpc_network.network-external.id}"

  ingress {
    protocol       = "TCP"
    description    = "Rule description 1"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    #security_groups  = [yandex_vpc_default_security_group.bastion-sg.id]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "ANY"
    v4_cidr_blocks= ["0.0.0.0/0"]
  }
    
}


resource "yandex_vpc_route_table" "external" {
  network_id     = "${yandex_vpc_network.network-external.id}" 
  depends_on = [yandex_vpc_subnet.subnet-external-bastion] 
  
  static_route {
    destination_prefix = "172.16.17.0/28"
    next_hop_address   = "yandex_compute_instance.nat-instance.network_interface.0.ip_address"
  }
}

resource "yandex_vpc_route_table" "internal" {
  network_id     = "${yandex_vpc_network.network-external.id}" 
  
  depends_on = [yandex_vpc_subnet.subnet-external-bastion] 
  static_route {
    destination_prefix = "172.16.16.0/28"
    next_hop_address   = "yandex_compute_instance.nat-instance.network_interface.0.ip_address"
  }
}








