data "yandex_compute_image" "ubuntu_ruby_mongodb_image" {
  family    = "ubuntu-1604-ruby-mongodb"
  folder_id = var.folder_id
}

resource "yandex_compute_instance" "server1" {
  name        = "server1"
  platform_id = var.platform_id
  zone        = yandex_vpc_subnet.otus_subnet_1.zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_ruby_mongodb_image.id
      type     = "network-hdd"
      size     = data.yandex_compute_image.ubuntu_ruby_mongodb_image.min_disk_size
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.otus_subnet_1.id
    nat       = false
  }

  metadata = {
    user-data = "${file("metadata1.yaml")}"
  }

  labels = {
    owner = var.owner
  }
}

resource "yandex_compute_instance" "server2" {
  name        = "server2"
  platform_id = var.platform_id
  zone        = yandex_vpc_subnet.otus_subnet_2.zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_ruby_mongodb_image.id
      type     = "network-hdd"
      size     = data.yandex_compute_image.ubuntu_ruby_mongodb_image.min_disk_size
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.otus_subnet_2.id
    nat       = false
  }

  metadata = {
    user-data = "${file("metadata2.yaml")}"
  }

  labels = {
    owner = var.owner
  }
}
