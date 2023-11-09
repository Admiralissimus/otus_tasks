resource "yandex_lb_target_group" "otus_tg" {
  name      = "otus-target-group"
  region_id = "ru-central1"

  target {
    subnet_id = yandex_vpc_subnet.otus_subnet_1.id
    address   = yandex_compute_instance.server1.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.otus_subnet_2.id
    address   = yandex_compute_instance.server2.network_interface.0.ip_address
  }
}

resource "yandex_lb_network_load_balancer" "otus_lb" {
  name = "otus-load-balancer"

  listener {
    name        = "puma-listener"
    port        = 80
    target_port = 9292
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.otus_tg.id

    healthcheck {
      name = "http"
      http_options {
        port = 9292
      }
    }
  }
}
