##network
resource "yandex_vpc_network" "network-elvm" {
  name = "network-elvm"
}

## subnet

resource "yandex_vpc_subnet" "subnet-a" {
  name           = "subnet-a"
  description    = "subnet-a description"
  v4_cidr_blocks = ["172.16.10.0/24"]
  zone           = "${var.zone_data["zone_a"]}"
  network_id     = "${yandex_vpc_network.network-elvm.id}" #network-elvm
}


resource "yandex_vpc_subnet" "subnet-b" {
  name           = "subnet-b"
  description    = "subnet-b description"
  v4_cidr_blocks = ["172.16.11.0/24"]
  zone           = "${var.zone_data["zone_b"]}"
  network_id     = "${yandex_vpc_network.network-elvm.id}"  #network-elvm
}


resource "yandex_vpc_subnet" "subnet-internal-bastion" {
  name           = "subnet-internal-bastion"
  description    = "myNetwork-subnet description" 
  v4_cidr_blocks = ["172.16.16.0/24"]
  zone           = "${var.zone_data["zone_a"]}"
  network_id     = "${yandex_vpc_network.network-elvm.id}" #network-bastion-internal
}

############################# external - внешний ##############################

##network

resource "yandex_vpc_network" "external-bastion-network" {
  name        = "external-bastion-network"
  description = "external network"
}
resource "yandex_vpc_subnet" "subnet-external-bastion" {
  name           = "subnet-external-bastion"
  description    = "external bastion" 
  v4_cidr_blocks = ["172.16.17.0/28"]
  zone           = "${var.zone_data["zone_a"]}"
  network_id     = "${yandex_vpc_network.external-bastion-network.id}" #network-bastion-external
}


#############secure group 
## external

resource "yandex_vpc_default_security_group" "secure-bastion-sg" {
 # name        = "secure-bastion-sg"
  description = "Description for security group"
  network_id  = "${yandex_vpc_network.external-bastion-network.id}"

  ingress {
    protocol       = "TCP"
    description    = "Rule description 1"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
}

## internal

resource "yandex_vpc_default_security_group" "internal-bastion-sg" {
#  name        = "internal-bastion-sg"
  description = "Description for security internal group"
  network_id  = "${yandex_vpc_network.network-elvm.id}"

  ingress {
    protocol       = "TCP"
    description    = "Rule description internal ingress 1"
    v4_cidr_blocks = ["172.16.16.0/24"]    
   # v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  
   egress {
    protocol       = "TCP"
    description    = "Rule description internal egress 1"
    v4_cidr_blocks = ["172.16.10.0/24", "172.16.11.0/24", "172.16.16.0/24", "172.16.17.0/24" ]
    from_port      = 0
    to_port        = 80
  }
   
  
}
