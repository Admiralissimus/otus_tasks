# 08 YC Terraform Packer LoadBalancer

## Create load balancer and 2 instances using terraform

### 1. Initialize terraform

Create **provider.tf** file

```hcl
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
```

```bash
$ export YC_TOKEN=$(yc iam create-token)
$ export YC_CLOUD_ID=$(yc config get cloud-id)
$ export YC_FOLDER_ID=$(yc config get folder-id)

$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of yandex-cloud/yandex...
- Installing yandex-cloud/yandex v0.102.0...
- Installed yandex-cloud/yandex v0.102.0 (unauthenticated)

...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Yandex token will be used by environment variable **YC_TOKEN**.

```bash
export YC_TOKEN=xxxxxxxxxxx
```

Create image with **Ubuntu + ruby + mongodb** using packer and scripts from 07_YC task.

ubuntu_ruby_mongodb.json

```json
{
    "builders": [
        {
            "type": "yandex",
            "zone": "ru-central1-a",
            "folder_id": "b1grlgcpgp7enm4j8knb",
            "source_image_family": "ubuntu-1604-lts",
            "image_name": "ubuntu-1604-ruby-mongodb-{{isotime | clean_resource_name}}",
            "image_family": "ubuntu-1604-ruby-mongodb",
            "image_description": "Ubuntu 16.04 with ruby and mongodb.",
            "use_ipv4_nat": true,
            "ssh_username": "ubuntu",
            "disk_size_gb": 3
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "07_YC_Packer_immutable_baked/scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "07_YC_Packer_immutable_baked/scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"
        }
    ]
}
```

```bash
$ packer validate ubuntu_ruby_mongodb.json 
The configuration is valid.

$ packer build ubuntu_ruby_mongodb.json 
yandex: output will be in this color.

==> yandex: Creating temporary RSA SSH key for instance...
==> yandex: Using as source image: fd842allqn7fhfrorfao (name: "ubuntu-16-04-lts-v20231106", family: "ubuntu-1604-lts")
==> yandex: Creating network...
==> yandex: Creating subnet in zone "ru-central1-a"...
==> yandex: Creating disk...
==> yandex: Creating instance...

...

Build 'yandex' finished after 4 minutes 36 seconds.

==> Wait completed after 4 minutes 36 seconds

==> Builds finished. The artifacts of successful builds are:
--> yandex: A disk image was created: ubuntu-1604-ruby-mongodb-2023-11-08t17-51-10z (id: fd8aal63tn4cmd928ksm) with family name ubuntu-1604-ruby-mongodb
```

Add datasource with the latest image_id to instances.tf:

```hcl
data "yandex_compute_image" "ubuntu_ruby_mongodb_image" {
  family    = "ubuntu-1604-ruby-mongodb"
  folder_id = var.folder_id
}
```

```bash
$ terraform plan
data.yandex_compute_image.ubuntu_ruby_mongodb_image: Reading...
data.yandex_compute_image.ubuntu_ruby_mongodb_image: Read complete after 7s [id=fd8aal63tn4cmd928ksm]

Changes to Outputs:
  + image_id = "fd8aal63tn4cmd928ksm"

```

As we can see, image_ids after **yc** and **terraform** commands are the same.

Create two subnets in different zones:

```hcl
resource "yandex_vpc_network" "otus_vpc" {}

resource "yandex_vpc_subnet" "otus_subnet_1" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.otus_vpc.id
  v4_cidr_blocks = ["10.10.0.0/24"]
}

resource "yandex_vpc_subnet" "otus_subnet_2" {
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.otus_vpc.id
  v4_cidr_blocks = ["10.10.10.0/24"]
}
```

Create two instances in two different zones with different web-interfaces (they get different commits from github).

```hcl
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
    nat       = true
  }

  metadata = {
    user-data = "${file("metadata1.yaml")}"
  }

  labels = {
    owner = var.owner
  }
}
```

Install web application by using **metadata.yaml** file.

```yaml
#cloud-config
users:
  - name: ubuntu
    groups: sudo
    shell: /bin/bash
    sudo: 'ALL=(ALL) NOPASSWD:ALL'

packages:
 - git
 
runcmd:
  - useradd -m -U -d /var/puma puma
  - cd /var/puma
  - git clone -b monolith https://github.com/admiralissimus/reddit.git
  - cd reddit 
  - git checkout 2b9f78b3232d732bebb7de1a2d0e475aea90d73c
  - cp ./puma.service /etc/systemd/system/puma.service 
  - bundle install
  - chown root:root /etc/systemd/system/puma.service
  - systemctl start puma
  - systemctl enable puma
```

Create **target group** and conneect it to the servers.

```hcl
resource "yandex_lb_target_group" "foo" {
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
```

Create **Load balancer**.

```hcl
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
```
