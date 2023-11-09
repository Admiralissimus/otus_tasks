resource "yandex_vpc_network" "otus_vpc" {
  name = "otus_vpc"
}

resource "yandex_vpc_subnet" "otus_subnet_1" {
  name           = "otus_subnet_1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.otus_vpc.id
  v4_cidr_blocks = ["10.10.0.0/24"]
}

resource "yandex_vpc_subnet" "otus_subnet_2" {
  name           = "otus_subnet_2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.otus_vpc.id
  v4_cidr_blocks = ["10.10.10.0/24"]
}
