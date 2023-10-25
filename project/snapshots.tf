resource "yandex_compute_snapshot_schedule" "snapshot" {
  name = "snapshots-elvm"
  schedule_policy {
	expression = "0 21 ? * *"
  }
  retention_period = "168h"
  snapshot_spec {
	  description = "retention-snapshot"      
  }

  disk_ids = ["${yandex_compute_instance.bastion-elvm.boot_disk[0].disk_id}",
              "${yandex_compute_instance.websrv-elvm-1.boot_disk[0].disk_id}",
              "${yandex_compute_instance.websrv-elvm-2.boot_disk[0].disk_id}",
              "${yandex_compute_instance.zabbix-elvm.boot_disk[0].disk_id}",
              "${yandex_compute_instance.elastic-elvm.boot_disk[0].disk_id}",
              "${yandex_compute_instance.kibana-elvm.boot_disk[0].disk_id}",]
}

# resource "yandex_compute_snapshot" "snapshot1" {
  # name        = "${var.hostnames[0]}"
  # description = "snapshot-${var.hostnames[0]}"
  # source_disk_id  = yandex_compute_instance.bastion-elvm.boot_disk[0].disk_id  
# }
# resource "yandex_compute_snapshot" "snapshot2" {
  # name        = "${var.hostnames[1]}"
  # description = "snapshot-${var.hostnames[1]}"
  # source_disk_id  = yandex_compute_instance.websrv-elvm-1.boot_disk[0].disk_id  
# }
# resource "yandex_compute_snapshot" "snapshot3" {
  # name        = "${var.hostnames[2]}"
  # description = "snapshot-${var.hostnames[2]}"
  # source_disk_id  = yandex_compute_instance.websrv-elvm-2.boot_disk[0].disk_id  
# }
# resource "yandex_compute_snapshot" "snapshot4" {
  # name        = "${var.hostnames[3]}"
  # description = "snapshot-${var.hostnames[3]}"
  # source_disk_id  = yandex_compute_instance.zabbix-elvm.boot_disk[0].disk_id  
# }
# resource "yandex_compute_snapshot" "snapshot5" {
  # name        = "${var.hostnames[4]}"
  # description = "snapshot-${var.hostnames[4]}"
  # source_disk_id  = yandex_compute_instance.elastic-elvm.boot_disk[0].disk_id  
# }
# resource "yandex_compute_snapshot" "snapshot6" {
  # name        = "${var.hostnames[5]}"
  # description = "snapshot-${var.hostnames[5]}"
  # source_disk_id  = yandex_compute_instance.kibana-elvm.boot_disk[0].disk_id  
# }