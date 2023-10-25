terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {  
  token                    = "${var.ya_cloud["token"]}"
  cloud_id                 = "${var.ya_cloud["cloud"]}"
  folder_id                = "${var.ya_cloud["folder"]}"
}