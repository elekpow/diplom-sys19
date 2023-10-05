####### external
resource "yandex_vpc_network" "external-bastion-network" {
  name        = "external-bastion-network"
  description = "external-bastion-network"
}

resource "yandex_vpc_subnet" "bastion-external-segment" {
  name           = "bastion-external-segment"
  description    = "bastion-external-segment"
  v4_cidr_blocks = ["172.16.17.0/28"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.external-bastion-network.id}"
}

######## internal
resource "yandex_vpc_network" "internal-bastion-network" {
  name        = "internal-bastion-network"
  description = "internal-bastion-network"
}

resource "yandex_vpc_subnet" "bastion-internal-segment" {
  name           = "bastion-internal-segment"
  description    = "bastion-internal-segment"
  v4_cidr_blocks = ["172.16.16.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.internal-bastion-network.id}"
}

####### secure external

resource "yandex_vpc_security_group" "internal-bastion-sg" {
  name        = "secure-bastion-sg"
  description = ""
  network_id  = "${yandex_vpc_network.external-bastion-network.id}"

  ingress {
    protocol       = "TCP"
    description    = ""
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

}

####### secure internal

resource "yandex_vpc_security_group" "internal-bastion-sg" {
  name        = "internal-bastion-sg"
  description = ""
  network_id  = "${yandex_vpc_network.internal-bastion-network.id}"

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
