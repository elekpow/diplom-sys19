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

resource "yandex_vpc_subnet" "subnet-b" { 
  name           = "subnet-b"
  description    = "myNetwork-subnet-b description" 
  v4_cidr_blocks = ["172.16.122.0/24"]
  zone           = "${var.zone_data["zone_b"]}"
  network_id     = "${yandex_vpc_network.network-elvm.id}" 
  depends_on = [yandex_vpc_network.network-elvm] 
  
}



###security_group####

resource "yandex_vpc_default_security_group" "bastion-sg" {
 # name        = "bastion-sg"
  description = "Description for security group"
  network_id  = "${yandex_vpc_network.network-elvm.id}"

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "proxy"
    v4_cidr_blocks = ["172.16.120.0/24","172.16.121.0/24","172.16.122.0/24"]
    port           = 3128
  }
  
  egress {
    protocol       = "ANY"
    description    = "ping"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 65535
  } 
      
}

resource "yandex_vpc_security_group" "internal-sg" {
  name        = "internal-sg"
  description = "Description for security group"
  network_id  = "${yandex_vpc_network.network-elvm.id}"


 ingress {
    description    = "ssh"
    protocol = "TCP"
    v4_cidr_blocks= ["172.16.120.0/24","172.16.121.0/24","172.16.122.0/24"]
    port           = 22
  }

 ingress {
    protocol       = "TCP"
    description    = "http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
    
  ingress {
    protocol       = "TCP"
    description    = "http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  } 

  
   egress {
    description    = "ANY"
    protocol       = "ANY"
    v4_cidr_blocks= ["0.0.0.0/0"]
	from_port      = 0
    to_port        = 65535
  }

  egress {
    protocol       = "TCP"
    description    = "proxy"
    v4_cidr_blocks = ["172.16.120.254/32"]
    port           = 3128
  }

      
}

resource "yandex_vpc_security_group" "lbalanser-sg" {
  name        = "lbalanser-sg"
  description = "security group for lbalanser"
  network_id  = "${yandex_vpc_network.network-elvm.id}"

  ingress {
    protocol       = "ANY"
    description    = "Lbalanser"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  } 
  
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

resource "yandex_vpc_security_group" "elastic-elvm-sg" {
  name        = "elastic-elvm-sg"
  description = "security group for elastic-elvm"
  network_id  = "${yandex_vpc_network.network-elvm.id}"

  ingress {
    description    = "elasticsearch"
    protocol = "TCP"
    v4_cidr_blocks= ["172.16.120.0/24","172.16.121.0/24","172.16.122.0/24" ]
    port           = 9200
  } 
  
   egress {
    description    = "elasticsearch"
    protocol = "TCP"
    v4_cidr_blocks= ["172.16.120.0/24","172.16.121.0/24","172.16.122.0/24"]
    port           = 5601
  } 
  
  
}

resource "yandex_vpc_security_group" "kibana-elvm" {
  name        = "kibana-elvm"
  description = "security group for kibana-elvm"
  network_id  = "${yandex_vpc_network.network-elvm.id}"

  ingress {
    description    = "kibana-elvm"
    protocol = "TCP"
    v4_cidr_blocks= ["172.16.120.0/24","172.16.121.0/24","172.16.122.0/24" ]
    port           = 5601
  } 
  
   egress {
    description    = "kibana-elvm"
    protocol = "TCP"
    v4_cidr_blocks= ["172.16.120.0/24","172.16.121.0/24","172.16.122.0/24"]
    port           = 9201
  } 
  
  
}

resource "yandex_vpc_security_group" "zabbix-elvm" {
  name        = "zabbix-elvm"
  description = "security group for kibana-elvm"
  network_id  = "${yandex_vpc_network.network-elvm.id}"

  ingress {
    description    = "zabbix-elvm"
    protocol = "TCP"
    v4_cidr_blocks= ["172.16.120.0/24","172.16.121.0/24","172.16.122.0/24" ]
    port           = 10050
  } 
  
   egress {
    description    = "zabbix-elvm"
    protocol = "TCP"
    v4_cidr_blocks= ["172.16.120.0/24","172.16.121.0/24","172.16.122.0/24"]
    port           = 10050
  } 
  
  
}

