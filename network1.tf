#network 2
resource "yandex_vpc_network" "network-external" { 
  name = "external-bastion"
}

resource "yandex_vpc_subnet" "subnet-a" { 
  name           = "subnet-a"
  description    = "myNetwork-subnet-a description" 
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "${var.zone_data["zone_a"]}"
  network_id     = "${yandex_vpc_network.network-external.id}" 
  depends_on = [yandex_vpc_network.network-external] 
  
}

resource "yandex_vpc_subnet" "subnet-internal-bastion" { 
  name           = "subnet-internal-bastion"
  description    = "myNetwork-subnet description" 
  v4_cidr_blocks = ["192.168.20.0/24"]
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
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  
  ingress {
    protocol       = "ICMP"
    description    = "ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 65535
  } 
  
  egress {
    port           = 22
    protocol = "TCP"
    v4_cidr_blocks= ["0.0.0.0/0"]
  }
    
}

resource "yandex_vpc_security_group" "internal-sg" {
  name        = "internal-sg"
  description = "Description for security group"
  network_id  = "${yandex_vpc_network.network-external.id}"

  ingress {
    protocol       = "ICMP"
    description    = "ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 65535
  }
    ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["192.168.20.0/24"]
    port           = 22
  }
  
   ingress {
    protocol       = "TCP"
    description    = "http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  
  egress {
    port           = 80
    description    = "http"
    protocol = "TCP"
    v4_cidr_blocks= ["0.0.0.0/0"]
  }
    
}