variable "ssh_user" {
  type = string
  default = "igor"
}

variable "zone_data" {
  type = map
  default = {
   "zone_a" = "ru-central1-a"
   "zone_b" = "ru-central1-b"
   "zone_c" = "ru-central1-c"
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
    "0" = "websrv-elvm-1"
    "1" = "websrv-elvm-2"
#    "2" = "slave2"
#    "3" = "slave2"
#    "4" = "slave2"
#    "5" = "slave2"
#    "5" = "slave2"
  }
}

variable "images" {
  type = map
  default = {
    "debian_10" = "fd8suc83g7bvp2o7edee"
    "debian_11" = "fd8il24jjf1hg8d4nq7i"
    "ubuntu_22" = "fd80bm0rh4rkepi5ksdi"
    "centos_7" = "fd8iqpj5nifue99bshhi"
  }
}

