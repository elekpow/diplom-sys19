resource "yandex_vpc_network" "my-external-Network" {
  name        = "external-bastion-network"
  description = "my-internal-Network decsription"
  labels = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_vpc_subnet" "my-external-subnet" {
  name           = "bastion-external-segment"
  description    = "myNetwork-subnet description"
  v4_cidr_blocks = ["172.16.17.0/28"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.my-external-Network.id}"
}

##security_group
resource "yandex_vpc_default_security_group" "secure-bastion-sg" {
#  name        = "secure-bastion-sg"
  description = "secure-bastion-sg"
  network_id  = "${yandex_vpc_network.my-external-Network.id}"

  labels = {
    my-label = "my-label-value"
  }


  ingress {
    protocol       = "TCP"
    description    = ""
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

}

#####################################################

resource "yandex_vpc_network" "my-internal-Network" {
  name        = "internal-bastion-network"
  description = "my-internal-Network decsription"
  labels = {
    tf-label    = "tf-label-value"
#    empty-label = ""
  }
}

resource "yandex_vpc_subnet" "my-internal-subnet" {
  name           = "bastion-internal-segment"
  description    = "myNetwork-subnet description"
  v4_cidr_blocks = ["172.16.16.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.my-internal-Network.id}"
}

##security_group
resource "yandex_vpc_default_security_group" "internal-bastion-sg" {
#  name        = "internal-bastion-sg"
  description = "internal-bastion-sg"
  network_id  = "${yandex_vpc_network.my-internal-Network.id}"

  labels = {
    my-label = "my-label-value"
  }

  ingress {
    protocol       = "TCP"
    description    = ""
    v4_cidr_blocks = ["172.16.16.254/32"]
    port           = 22
  }

  egress {
    protocol       = "TCP"
    description    = ""
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 22
  }

}


resource "yandex_vpc_subnet" "subnet-a" {
  name           = "subnet-a"
  description    = "subnet-a description"
  v4_cidr_blocks = ["172.16.10.0/24"]
  zone           = "${var.zone_data["zone_a"]}"
  network_id     = "${yandex_vpc_network.my-internal-Network.id}"
}


resource "yandex_vpc_subnet" "subnet-b" {
  name           = "subnet-b"
  description    = "subnet-b description"
  v4_cidr_blocks = ["172.16.20.0/24"]
  zone           = "${var.zone_data["zone_b"]}"
  network_id     = "${yandex_vpc_network.my-internal-Network.id}"
}























