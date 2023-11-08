# 7 YC packer immutable baked image

## 1. Install packer

## 2. Configure packer

## 3. Create immutable image with working app

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

```hcl
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

install_mongodb.sh

```bash
#!/bin/bash
set -e

# Install MongoDB
apt-get update
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D68FA50FEA312927
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list
apt-get update
apt-get install --assume-yes mongodb-org
systemctl start mongod
systemctl enable mongod
```

install_ruby.sh

```bash
#!/bin/bash
set -e

# Install ruby
apt-get update
apt-get install --assume-yes ruby-full ruby-bundler build-essential 
```

install_puma.sh

```bash
#!/bin/bash
set -e
apt-get update
apt-get install -y git
useradd -m -U -d /var/puma puma
cd /var/puma
git clone -b monolith https://github.com/admiralissimus/reddit.git
cd reddit && bundle install
systemctl start puma
systemctl enable puma
```

Yandex token will be used by environment variable **YC_TOKEN**.

```bash
export YC_TOKEN=xxxxxxxxxxx
```

Create a JSON file **ubuntu.json**.

ubuntu.json

```json
{
    "builders": [
        {
            "type": "yandex",
            "zone": "ru-central1-a",
            "folder_id": "b1g6mmcu4pmqf10ge9g2",
            "source_image_family": "ubuntu-1604-lts",
            "image_name": "my-ubuntu-1604-{{timestamp}}",
            "image_description": "My ubuntu image created by packer",
            "use_ipv4_nat": true,
            "ssh_username": "ubuntu",
            "disk_size_gb": 3
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "file",
            "source": "puma.service",
            "destination": "/tmp/puma.service"
        },
        {
            "type": "shell",
            "script": "scripts/install_puma.sh",
            "execute_command": "sudo {{.Path}}"
        }
    ]
}
```

```bash
$ packer validate ubuntu.json
The configuration is valid.

$ packer build ubuntu.json   
yandex: output will be in this color.

==> yandex: Creating temporary RSA SSH key for instance...
==> yandex: Using as source image: fd842allqn7fhfrorfao (name: "ubuntu-16-04-lts-v20231106", family: "ubuntu-1604-lts")
==> yandex: Creating network...
==> yandex: Creating subnet in zone "ru-central1-a"...
==> yandex: Creating disk...
==> yandex: Creating instance...
==> yandex: Waiting for instance with id fhmd751fih1h3e385eh3 to become active...
    yandex: Detected instance IP: 158.160.96.57
==> yandex: Using SSH communicator to connect: 158.160.96.57
==> yandex: Waiting for SSH to become available...
==> yandex: Connected to SSH!
==> yandex: Provisioning with shell script: scripts/install_mongodb.sh
    yandex: Hit:1 http://mirror.yandex.ru/ubuntu xenial InRelease

...

==> yandex: Provisioning with shell script: scripts/install_ruby.sh
    yandex: Hit:1 http://mirror.yandex.ru/ubuntu xenial InRelease

...


==> yandex: Provisioning with shell script: /tmp/packer-shell3076935872
==> yandex: Provisioning with shell script: scripts/install_puma.sh
    yandex: Hit:1 http://mirror.yandex.ru/ubuntu xenial InRelease

...


==> yandex: Created symlink from /etc/systemd/system/multi-user.target.wants/puma.service to /etc/systemd/system/puma.service.
    yandex:
==> yandex: Stopping instance...
==> yandex: Deleting instance...
    yandex: Instance has been deleted!
==> yandex: Creating image: my-ubuntu-1604-1699279463
==> yandex: Waiting for image to complete...
==> yandex: Success image create...
==> yandex: Destroying subnet...
    yandex: Subnet has been deleted!
==> yandex: Destroying network...
    yandex: Network has been deleted!
==> yandex: Destroying boot disk...
    yandex: Disk has been deleted!
Build 'yandex' finished after 8 minutes 58 seconds.

==> Wait completed after 8 minutes 58 seconds

==> Builds finished. The artifacts of successful builds are:
--> yandex: A disk image was created: my-ubuntu-1604-1699279463 (id: fd8hbc8dj9kujhp6bbae) with family name 

```

Check image:

```bash
$ yc compute image list  
+----------------------+---------------------------+--------+----------------------+--------+
|          ID          |           NAME            | FAMILY |     PRODUCT IDS      | STATUS |
+----------------------+---------------------------+--------+----------------------+--------+
| fd8hbc8dj9kujhp6bbae | my-ubuntu-1604-1699279463 |        | f2ee0c0m0uomrqbss4c7 | READY  |
+----------------------+---------------------------+--------+----------------------+--------+
```

Create new instance with the image **without access via SSH**.

```bash
$ yc compute instance create \
  --name puma-instance \
  --zone ru-central1-a \
  --network-interface subnet-id=e9b6ppr3mbccdlbnvge7,nat-ip-version=ipv4 \
  --preemptible \
  --create-boot-disk image-id=fd8hbc8dj9kujhp6bbae \       
  --core-fraction 20 \
  --memory 1 

done (1m5s)
id: fhmsvsp160t7gkbicaqj
folder_id: b1g6mmcu4pmqf10ge9g2
created_at: "2023-11-06T16:36:18Z"
name: puma-instance
zone_id: ru-central1-a
platform_id: standard-v2
resources:
  memory: "1073741824"
  cores: "2"
  core_fraction: "20"
status: RUNNING
metadata_options:
  gce_http_endpoint: ENABLED
  aws_v1_http_endpoint: ENABLED
  gce_http_token: ENABLED
  aws_v1_http_token: DISABLED
boot_disk:
  mode: READ_WRITE
  device_name: fhm4epk8phuheoqp0acj
  auto_delete: true
  disk_id: fhm4epk8phuheoqp0acj
network_interfaces:
  - index: "0"
    mac_address: d0:0d:1c:ff:32:13
    subnet_id: e9b6ppr3mbccdlbnvge7
    primary_v4_address:
      address: 10.128.0.34
      one_to_one_nat:
        address: 158.160.104.27
        ip_version: IPV4
gpu_settings: {}
fqdn: fhmsvsp160t7gkbicaqj.auto.internal
scheduling_policy:
  preemptible: true
network_settings:
  type: STANDARD
placement_policy: {}
```

Check working the puma service

```html
$ curl 158.160.104.27:9292
<!DOCTYPE html>
<html lang='en'>
<head>
<meta charset='utf-8'>
<meta content='IE=Edge,chrome=1' http-equiv='X-UA-Compatible'>
<meta content='width=device-width, initial-scale=1.0' name='viewport'>
<title>Monolith Reddit :: All posts</title>
<link crossorigin='anonymous' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css' integrity='sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7' rel='stylesheet' type='text/css'>
<link crossorigin='anonymous' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css' integrity='sha384-fLW2N01lMqjakBkx3l/M9EahuwpSfeNvV63J5ezn3uZzapT0u7EYsXMjQV+0En5r' rel='stylesheet' type='text/css'>
<script crossorigin='anonymous' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js' integrity='sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS'></script>
<script src='https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js'></script>
</head>
<body>
<div class='navbar navbar-default navbar-static-top'>
<div class='container'>
<div class='navbar-header'>
<button class='navbar-toggle' data-target='.navbar-responsive-collapse' data-toggle='collapse' type='button'>
<span class='icon-bar'></span>
<span class='icon-bar'></span>
<span class='icon-bar'></span>
</button>
<a class='navbar-brand' href='/'>Monolith Reddit</a>
</div>
<div class='navbar-collapse collapse'>
<ul class='nav navbar-nav navbar-right'>
<li>
<a href='/signup'>Sign up</a>
</li>
<li>
<a href='/login'>Login</a>
</li>
</ul>
</div>
</div>
</div>
<div class='container'>
<div class='row'>
<div class='col-lg-9'>

</div>
<div class='col-lg-3'>
<div class='well sidebar-nav'>
<h3>Menu</h3>
<ul class='nav nav-list'>
<li>
<a href='/'>All posts</a>
</li>
<li>
<a href='/new'>New post</a>
</li>
</ul>
</div>
</div>
</div>
</div>
</body>
</html>
```

## Baked image is ready
