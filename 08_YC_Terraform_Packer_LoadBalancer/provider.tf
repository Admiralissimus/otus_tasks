terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  zone = "var.az_default"
}

data "yandex_compute_image" "ubuntu_ruby_mongodb_image" {
  family    = "ubuntu-1604-ruby-mongodb"
  folder_id = var.folder_id
}
