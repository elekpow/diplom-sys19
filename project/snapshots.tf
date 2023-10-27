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
