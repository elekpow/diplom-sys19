#network 2
resource "yandex_vpc_network" "network-external" { 
  name = "external-bastion"
}

resource "yandex_vpc_subnet" "subnet-a" { 
  name           = "subnet-a"
  description    = "myNetwork-subnet-a description" 
  v4_cidr_blocks = ["10.128.0.0/24"]
  zone           = "${var.zone_data["zone_a"]}"
  network_id     = "${yandex_vpc_network.network-external.id}" 
  depends_on = [yandex_vpc_network.network-external] 
  
}

resource "yandex_vpc_subnet" "subnet-b" { 
  name           = "subnet-b"
  description    = "myNetwork-subnet-b description" 
  v4_cidr_blocks = ["10.129.0.0/24"]
  zone           = "${var.zone_data["zone_b"]}"
  network_id     = "${yandex_vpc_network.network-external.id}" 
  depends_on = [yandex_vpc_network.network-external] 
  
}

resource "yandex_vpc_subnet" "subnet-internal-bastion" { 
  name           = "subnet-internal-bastion"
  description    = "myNetwork-subnet description" 
  v4_cidr_blocks = ["10.130.0.0/24"]
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
    v4_cidr_blocks = ["10.130.0.0/24"]
    port           = 22
  }
  
   ingress {
    protocol       = "TCP"
    description    = "http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  
  
 ingress {
    description    = "zabbix"
    protocol = "TCP"
    v4_cidr_blocks= ["10.128.0.0/24","10.129.0.0/24","10.130.0.0/24"]
    port           = 10050
  } 
  
   ############# 
  ingress {
    protocol       = "TCP"
    description    = "Lbalanser"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  } 
  
   ingress {
    protocol       = "TCP"
    description    = "Lbalanser"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 30080 
  } 
   
    ingress {
    protocol       = "TCP"
    description    = "Lbalanser"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  } 
 
  ingress {
    description    = "elasticsearch"
    protocol = "TCP"
    v4_cidr_blocks= ["10.128.0.0/24","10.129.0.0/24","10.130.0.0/24" ]
    port           = 9200
  } 
  
  ingress {
    description    = "kibana"
    protocol = "TCP"
    v4_cidr_blocks= ["0.0.0.0/0"]
    port           = 5601
  } 
  
  egress {
    port           = 80
    description    = "http"
    protocol = "TCP"
    v4_cidr_blocks= ["0.0.0.0/0"]
  }
  
   egress {
    port           = 443
    description    = "https"
    protocol = "TCP"
    v4_cidr_blocks= ["0.0.0.0/0"]
  }
    
   egress {
    description    = "ping"
    protocol = "ICMP"
    v4_cidr_blocks= ["0.0.0.0/0"]
	from_port = 0
    to_port = 65535
  }    
    
    
    	
  egress {
    description    = "zabbix"
    protocol = "TCP"
    v4_cidr_blocks= ["10.128.0.0/24","10.129.0.0/24","10.130.0.0/24"]
    port           = 10050
  }
      		
  egress {
    description    = "elasticsearch"
    protocol = "TCP"
    v4_cidr_blocks= ["10.128.0.0/24","10.129.0.0/24","10.130.0.0/24"]
    port           = 9200
  } 
	
  egress {
    description    = "kibana"
    protocol = "TCP"
    v4_cidr_blocks= ["0.0.0.0/0"]	
    port           = 5601
  }    
    
    
	
}