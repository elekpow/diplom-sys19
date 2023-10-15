
variable "ssh_user_1" {
  type = string
  default = "igor"
}

variable "ssh_user_2" {
  type = string
  default = "bastion"
}

variable "ssh_user" {
  default = {
   "0" = "igor"
   "1" = "bastion"
  }
}

variable "zone_data" {
  type = map
  default = {
   "zone_a" = "ru-central1-a"
   "zone_b" = "ru-central1-b"
  }
}

variable "platform" {
  type = map
  default = {
  "v1" = "standard-v1"
  "v2" = "standard-v2"
  "v3" = "standard-v3"
  "gv1" = "gpu-standard-v1"
  }
}


variable "hostnames" {
  default = {
    "0" = "bastion-elvm" 
    "1" = "websrv-elvm-1"
    "2" = "websrv-elvm-2"
    "3" = "zabbix-elvm"
    "4" = "elastic-elvm"
    "5" = "kibana-elvm"
  }
}

variable "images" {
  type = map
  default = {
    "debian_10" = "fd8suc83g7bvp2o7edee"
    "debian_11" = "fd8il24jjf1hg8d4nq7i"
    "ubuntu_22" = "fd80bm0rh4rkepi5ksdi"
    "centos_7" = "fd8iqpj5nifue99bshhi"
	"ubuntu_nat_18" = "fd8h26vspaooq2rf6e2v" #nat-instance-ubuntu
	"ubuntu_nat_22" = "fd8i1dktc7d3h7nnlb9i" #nat-instance-ubuntu
  }
}
