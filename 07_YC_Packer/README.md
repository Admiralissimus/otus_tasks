# 7 YC packer

## 1. Install packer

## 2. Configure packer

## 3. Create image

## Installing packer locally

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install packer
```

Check installation:  

```bash
packer -v
1.9.4
```

## Configure packer

- Create a **config.pkr.hcl** file with the following contents:

```json
packer {
  required_plugins {
    yandex = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/yandex"
    }
  }
}
```

- Install the plugin:

```bash
$ packer init ./config.pkr.hcl
Installed plugin github.com/hashicorp/yandex v1.1.2 in ...
```

## Create image

### Prepare the image configuration  

Get the folder ID by running the **yc config list** command.  
Get the subnet ID by running the command **yc vpc subnet list**.

```bash
$ yc config list
token: y0_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
cloud-id: b1gbkrqtksdp22s6mpkd
folder-id: b1g6mmcu4pmqf10ge9g2
compute-default-zone: ru-central1-a

$ yc vpc subnet list
+----------------------+-----------------------+----------------------+----------------+---------------+-----------------+
|          ID          |         NAME          |      NETWORK ID      | ROUTE TABLE ID |     ZONE      |      RANGE      |
+----------------------+-----------------------+----------------------+----------------+---------------+-----------------+
| e2lg9dsod59dgr3ohbem | default-ru-central1-b | enpm9bafea9ivreluiih |                | ru-central1-b | [10.129.0.0/24] |
| e9bu15ncg56h9220c20j | default-ru-central1-a | enpm9bafea9ivreluiih |                | ru-central1-a | [10.128.0.0/24] |
+----------------------+-----------------------+----------------------+----------------+---------------+-----------------+

```

Find imege's id

```bash
$ yc compute image list --folder-id standard-images --format='json' | \
jq 'map(select(.family == "ubuntu-2204-lts"))' | \
jq 'sort_by(.created_at)' | \
jq '.[] | {family, id, created_at}' | \
tail -n 4 | head -n 3

  "family": "ubuntu-2204-lts",
  "id": "fd80bm0rh4rkepi5ksdi",
  "created_at": "2023-09-25T10:53:45Z"
```

Yandex token will be used by environment variable **YC_TOKEN**.

```bash
export YC_TOKEN=xxxxxxxxxxx
```

Create a JSON file **ubuntu.json**.

ubuntu.json

```json

```

install_mongodb.sh

```bash
#!/bin/bash
set -e

# Install MongoDB
apt-get update
NEEDRESTART_MODE=a apt-get install --assume-yes gnupg curl
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-7.0.list
apt-get update
DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt-get install --assume-yes mongodb-org
systemctl start mongod
systemctl enable mongod
```

install_ruby.sh

```bash
#!/bin/bash
set -e

# Install ruby
apt-get update
NEEDRESTART_MODE=a apt-get install --assume-yes ruby-full ruby-bundler build-essential 
```

```bash
$ packer validate ubuntu.json
The configuration is valid.

$ packer build ubuntu.json
yandex: output will be in this color.

==> yandex: Creating temporary RSA SSH key for instance...
==> yandex: Using as source image: fd8nru7hnggqhs9mkqps (name: "ubuntu-22-04-lts-v20231030", family: "ubuntu-2204-lts")
==> yandex: Creating network...
==> yandex: Creating subnet in zone "ru-central1-a"...
==> yandex: Creating disk...
==> yandex: Creating instance...
==> yandex: Waiting for instance with id fhmvs5lkn0vkkn05jnb8 to become active...
    yandex: Detected instance IP: 51.250.13.209
==> yandex: Using SSH communicator to connect: 51.250.13.209
==> yandex: Waiting for SSH to become available...
==> yandex: Connected to SSH!
==> yandex: Provisioning with shell script: scripts/install_ruby.sh
    yandex: Hit:1 http://mirror.yandex.ru/ubuntu jammy InRelease
    yandex: Get:2 http://mirror.yandex.ru/ubuntu jammy-updates InRelease [119 kB]

...

==> yandex: Provisioning with shell script: scripts/install_mongodb.sh
    yandex: Hit:1 http://mirror.yandex.ru/ubuntu jammy InRelease
    yandex: Hit:2 http://mirror.yandex.ru/ubuntu jammy-updates InRelease

...

==> yandex: Created symlink /etc/systemd/system/multi-user.target.wants/mongod.service → /lib/systemd/system/mongod.service.
==> yandex: Stopping instance...
==> yandex: Deleting instance...
    yandex: Instance has been deleted!
==> yandex: Creating image: my-ubuntu-2204-1699212535
==> yandex: Waiting for image to complete...
==> yandex: Success image create...
==> yandex: Destroying subnet...
    yandex: Subnet has been deleted!
==> yandex: Destroying network...
    yandex: Network has been deleted!
==> yandex: Destroying boot disk...
    yandex: Disk has been deleted!
Build 'yandex' finished after 5 minutes 56 seconds.

==> Wait completed after 5 minutes 56 seconds

==> Builds finished. The artifacts of successful builds are:
--> yandex: A disk image was created: my-ubuntu-2204-1699212535 (id: fd8b0r7dov6roso61m30) with family name 

```

Check image:

```bash
$ yc compute image list  
+----------------------+---------------------------+--------+----------------------+--------+
|          ID          |           NAME            | FAMILY |     PRODUCT IDS      | STATUS |
+----------------------+---------------------------+--------+----------------------+--------+
| fd8b0r7dov6roso61m30 | my-ubuntu-2204-1699212535 |        | f2ei22l6nf3sht9nlqrr | READY  |
+----------------------+---------------------------+--------+----------------------+--------+
```
