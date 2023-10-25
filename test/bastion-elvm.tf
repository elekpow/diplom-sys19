
resource "yandex_compute_snapshot_schedule" "snapshot" {
  name = "${var.hostnames[0]}"
  schedule_policy {
	expression = "0 0 * * *"
  }

  retention_period = "12h"

  snapshot_spec {
	  description = "retention-snapshot"
      
      labels = {
        snapshot-label = "spec-snapshot-${var.hostnames[0]}"
      }
  }



   labels = {
        snapshot-label = "schedule-snapshot-${var.hostnames[0]}"
   }

  disk_ids = ["${yandex_compute_instance.[var.hostnames[0]].boot_disk[0].disk_id}"]
}


resource "yandex_compute_snapshot" "snapshot" {
  name        = "my-snapshot"
  description = "Снимок диска"
  ##source_disk_id  = yandex_compute_disk.disk.id
  source_disk_id  = yandex_compute_instance.bastion-elvm.boot_disk[0].disk_id
  
}

# resource "yandex_compute_disk" "disk" {
  # name         = "my-disk"
  # description  = "This is my disk"
  # size         = 10
  # type         = "network-ssd"
  # image_id = "${var.images["debian_10"]}"
  # zone        = "${var.zone_data["zone_a"]}"
# }



resource "yandex_compute_instance" "bastion-elvm" {
  name = "${var.hostnames[0]}"
  platform_id = "${var.platform["v3"]}"
  zone        = "${var.zone_data["zone_a"]}"
  hostname = "${var.hostnames[0]}"

  resources {
    core_fraction = 20
    cores  = 2
    memory = 2
  }
  
  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = "${var.images["debian_10"]}"
      type = "network-ssd"
      size = "10"
     
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-internal-bastion.id                #subnet-internal-bastion
    nat       = true
    ip_address = "172.16.120.254"
  }

 
  metadata = {
    user-data = "${file("./metadata/bastion.yml")}"
    serial-port-enable = 1
  }
  
  
}

output "bastion-elvm" {
  value = yandex_compute_instance.bastion-elvm.network_interface.0.nat_ip_address
}
