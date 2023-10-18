resource "yandex_alb_target_group" "elvm-tg" {
  name           = "elvm-tg"

  target {
    subnet_id    = "${yandex_vpc_subnet.subnet-a.id}"
    ip_address   = "${yandex_compute_instance.websrv-elvm-1.network_interface.0.ip_address}"
  }

  target {
    subnet_id    = "${yandex_vpc_subnet.subnet-b.id}"
    ip_address   = "${yandex_compute_instance.websrv-elvm-2.network_interface.0.ip_address}"
  }
}
resource "yandex_alb_backend_group" "elvm-bk" {
  name                     = "elvm-bk"
  #session_affinity {
#    connection {
#      source_ip = <true_или_false>
#    }
#  }

  http_backend {
    name                   = "elvm-http-bk"
    weight                 = 1
    port                   = 80
    target_group_ids       = ["${yandex_alb_target_group.elvm-tg.id}"]
    # load_balancing_config {
      # panic_threshold      = 50
    # }    
    healthcheck {
      timeout              = "1s"
      interval             = "1s"
    #  healthy_threshold    = 10
   #   unhealthy_threshold  = 15 
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "elvm-router" {
  name          = "elvm-router"
  labels        = {
    tf-label    = "elvm-router-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "elvm-vh" {
  name                    = "elvm-vh"
  http_router_id          = yandex_alb_http_router.elvm-router.id
  route {
    name                  = "my-route"
    http_route {
      http_route_action {
        backend_group_id  = yandex_alb_backend_group.elvm-bk.id
        timeout           = "3s"
      }
    }
  }
}    

resource "yandex_alb_load_balancer" "elvm-balancer" {
  name        = "elvm-balancer"
  network_id  = "${yandex_vpc_network.network-external.id}"
  security_group_ids = [yandex_vpc_security_group.internal-sg.id]  

  allocation_policy {
    location {
      zone_id   = "${var.zone_data["zone_a"]}"
      subnet_id = "${yandex_vpc_subnet.subnet-a.id}"
    }
	
    location {
      zone_id   = "${var.zone_data["zone_b"]}"
      subnet_id = "${yandex_vpc_subnet.subnet-b.id}"
    }	
  }

  listener {
    name = "elvm-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.elvm-router.id
      }
    }
  }

  # log_options {
   # log_group_id = "<идентификатор_лог-группы>"
    # discard_rule {
      # http_codes          = ["200"]
      # http_code_intervals = ["HTTP_ALL"]
      # grpc_codes          = ["OK"]
      # discard_percent     = 75
    # }
  # }
}

output "lbalancer_ip-elvm" {
  description = "ALB public IPs"
  value       = yandex_alb_load_balancer.elvm-balancer.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
}
