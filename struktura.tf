resource "yandex_compute_instance" "vm-ter" {
  count = "${length(var.hostnames)}"
  name = "vm-ter-${count.index}"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"
  hostname = "${var.hostnames[count.index]}"
  
  resources {
    core_fraction = 20 
    cores  = 2
    memory = 2
  }
 
  boot_disk {
    initialize_params {
      image_id = "${var.images["debian_10"]}"
      type = "network-ssd"
      size = "10"
    }
  }

# secondary_disk {
     # auto_delete = false
#      disk_id = "yandex_compute_disk.myhdd[*].id"
		
#  }


  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_ter.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./metadata.yml")}"
    serial-port-enable = 1
  }
  
 provisioner "remote-exec" {
   inline = [
       "ls -la",
	# "sudo apt-get update",
       # "curl -fsSL https://get.docker.com -o install-docker.sh",
        #"sh install-docker.sh --dry-run",
       # "sh install-docker.sh",
	# "sudo apt-get install python-minimal -y",	
       # "sudo apt-get install cryptsetup -y",
       # "sudo apt install xrdp -y",

    ]
    connection {
     type = "ssh"
     user = "${var.ssh_user}" 
     host = self.network_interface.0.nat_ip_address
     agent = true # eval "$(ssh-agent -s)"; ssh-add ~/.ssh/id_rsa
   }
}

## ANSIBLE inventory
provisioner "local-exec" {
   command = "  echo '[${var.hostnames[count.index]}]\n${self.network_interface.0.nat_ip_address} \n' >> inventory"
 }

provisioner "local-exec" {
   command = " if [ ${count.index} -eq 2 ]; then echo '[all:vars] ansible_python_interpreter=/usr/bin/python3'; else echo ''; fi >> inventory"
 }

## ANSIBLE first install
 provisioner "local-exec" {
   command = "sleep 30; # ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ./inventory ./ansible/install.yml"
 }

}

## network
resource "yandex_vpc_network" "network_ter" {
  name = "net_ter[count.index]"
}
## network _ subnet
resource "yandex_vpc_subnet" "subnet_ter" {
  name           = "subnet_ter[count.index]"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network_ter.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

###### null_resource_inventory
  resource "null_resource" "vm-hosts" {
  provisioner "local-exec" {
    command = "rm -rf ./inventory"
  }
}


#resource "yandex_compute_disk" "myhdd" {
#  name       = "myhdd"
#  type       = "network-hdd"
#  zone       = "ru-central1-a"
#  size       = 1
#}
