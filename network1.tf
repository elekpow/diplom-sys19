

##network 1 network-elvm
resource "yandex_vpc_network" "network-elvm" {
  name = "network-elvm"
}

resource "yandex_vpc_subnet" "subnet-a" {
  name           = "subnet-a"
  description    = "subnet-a description"
  v4_cidr_blocks = ["172.16.10.0/24"]
  zone           = "${var.zone_data["zone_a"]}"
  network_id     = "${yandex_vpc_network.network-elvm.id}" #network-elvm
}

resource "yandex_vpc_security_group" "elvm_group_sg" {
 # name        = "secure-bastion-sg"
  description = "Description for security group"
  network_id  = "${yandex_vpc_network.network-elvm.id}"

  ingress {
    protocol       = "TCP"
    description    = "Rule description 1"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  
  ingress {
    protocol       = "TCP"
    description    = "Rule description 2"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  
  
  egress {
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