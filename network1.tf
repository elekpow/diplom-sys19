

<<<<<<< HEAD
resource "yandex_vpc_subnet" "subnet-a" { 
  name           = "subnet-a"
  description    = "myNetwork-subnet description" 
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "${var.zone_data["zone_a"]}"
  network_id     = "${yandex_vpc_network.network-external.id}" 
  depends_on = [yandex_vpc_network.network-external] 
  
}

resource "yandex_vpc_subnet" "subnet-internal-bastion" { 
  name           = "subnet-internal-bastion"
  description    = "myNetwork-subnet description" 
  v4_cidr_blocks = ["192.168.20.0/24"]
=======
##network 1 network-elvm
resource "yandex_vpc_network" "network-elvm" {
  name = "network-elvm"
}

resource "yandex_vpc_subnet" "subnet-a" {
  name           = "subnet-a"
  description    = "subnet-a description"
  v4_cidr_blocks = ["172.16.10.0/24"]
>>>>>>> 6ef18a3752a2a2137a60295501fddbce2d33a53a
  zone           = "${var.zone_data["zone_a"]}"
  network_id     = "${yandex_vpc_network.network-elvm.id}" #network-elvm
}

resource "yandex_vpc_security_group" "elvm_group_sg" {
 # name        = "secure-bastion-sg"
  description = "Description for security group"
  network_id  = "${yandex_vpc_network.network-elvm.id}"

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  
<<<<<<< HEAD
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

=======
>>>>>>> 6ef18a3752a2a2137a60295501fddbce2d33a53a
  ingress {
    protocol       = "ICMP"
    description    = "ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 65535
  }
    ingress {
    protocol       = "TCP"
<<<<<<< HEAD
    description    = "ssh"
    v4_cidr_blocks = ["192.168.20.0/24"]
    port           = 22
  }
  
   ingress {
    protocol       = "TCP"
    description    = "http"
=======
    description    = "Rule description 2"
>>>>>>> 6ef18a3752a2a2137a60295501fddbce2d33a53a
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  
  
  egress {
<<<<<<< HEAD
    port           = 80
    description    = "http"
    protocol = "TCP"
    v4_cidr_blocks= ["0.0.0.0/0"]
  }
    
}


=======
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  
}


##network 2 external-bastion-network

resource "yandex_vpc_network" "network-bastion" {
  name = "network-bastion"
}

## external bastion subnet
resource "yandex_vpc_subnet" "subnet-network-bastion" {
  name           = "subnet-network-bastion"
  description    = "external bastion" 
  v4_cidr_blocks = ["172.16.16.0/28"]
  zone           = "${var.zone_data["zone_a"]}"
  network_id     = "${yandex_vpc_network.network-bastion.id}" 
}

>>>>>>> 6ef18a3752a2a2137a60295501fddbce2d33a53a


resource "yandex_vpc_security_group" "bastion_group_sg" {
 # name        = "secure-bastion-sg"
  description = "Description for security group"
  network_id  = "${yandex_vpc_network.network-bastion.id}"

  ingress {
    protocol       = "TCP"
    description    = "Rule description 1"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  
  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  
}