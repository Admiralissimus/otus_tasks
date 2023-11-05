
# 6 YC CLI and deploying app

## 1. Create instance using yc app

## 2. Install Ruby and MongoDB

## 3. Deploy test app

### Create instance using yc app

```bash
yc compute instance create --help
```

Set default folder

```bash
yc config set folder-id <Folder-id>
```

Find ids of images.

```bash
yc compute image list --folder-id standard-images --format='json' | jq 'map(select(.family == "ubuntu-2204-lts"))' | jq 'sort_by(.created_at)' | jq '.[] | {family, id, created_at}'
```

```output
{
  "family": "ubuntu-2204-lts",
  "id": "fd8bkgba66kkf9eenpkb",
  "created_at": "2023-07-24T10:51:49Z"
}
{
  "family": "ubuntu-2204-lts",
  "id": "fd8clogg1kull9084s9o",
  "created_at": "2023-08-28T10:53:41Z"
}
{
  "family": "ubuntu-2204-lts",
  "id": "fd82nvvtllmimo92uoul",
  "created_at": "2023-09-11T10:53:12Z"
}
{
  "family": "ubuntu-2204-lts",
  "id": "fd830gae25ve4glajdsj",
  "created_at": "2023-09-18T10:53:56Z"
}
{
  "family": "ubuntu-2204-lts",
  "id": "fd80bm0rh4rkepi5ksdi",
  "created_at": "2023-09-25T10:53:45Z"
}
```

View subnets.

```bash
yc vpc subnet list
```

```output
+----------------------+---------------------------+----------------------+----------------+---------------+-----------------+
|          ID          |           NAME            |      NETWORK ID      | ROUTE TABLE ID |     ZONE      |      RANGE      |
+----------------------+---------------------------+----------------------+----------------+---------------+-----------------+
| b0c2u6i9bkmfdr9moh1i | default-vpc-ru-central1-c | enptekocg5sqrlep7j2c |                | ru-central1-c | [10.130.0.0/24] |
| e2l73ma11v7l0jjq309c | default-vpc-ru-central1-b | enptekocg5sqrlep7j2c |                | ru-central1-b | [10.129.0.0/24] |
| e9b6ppr3mbccdlbnvge7 | default-vpc-ru-central1-a | enptekocg5sqrlep7j2c |                | ru-central1-a | [10.128.0.0/24] |
+----------------------+---------------------------+----------------------+----------------+---------------+-----------------+
```

Create instance.

```bash
yc compute instance create \
  --name test-preemptible-instance \
  --zone ru-central1-a \
  --network-interface subnet-id=e9b6ppr3mbccdlbnvge7,nat-ip-version=ipv4 \
  --preemptible \
  --create-boot-disk image-id=fd80bm0rh4rkepi5ksdi,size=8 \
  --core-fraction 20 \
  --metadata-from-file user-data=metadata.yaml \
  --memory 1
```

User name will be **yc-user**.

```output
done (32s)
id: fhm6onfqbmmu8049fbm7
folder_id: b1g6mmcu4pmqf10ge9g2
created_at: "2023-11-05T10:44:41Z"
name: test-preemptible-instance
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
  device_name: fhmte9112c1pd27i2rk2
  auto_delete: true
  disk_id: fhmte9112c1pd27i2rk2
network_interfaces:
  - index: "0"
    mac_address: d0:0d:6c:5d:fa:5d
    subnet_id: e9b6ppr3mbccdlbnvge7
    primary_v4_address:
      address: 10.128.0.18
      one_to_one_nat:
        address: 158.160.126.88
        ip_version: IPV4
gpu_settings: {}
fqdn: fhm6onfqbmmu8049fbm7.auto.internal
scheduling_policy:
  preemptible: true
network_settings:
  type: STANDARD
placement_policy: {}
```

### Install Ruby and MongoDB

For installation of Ruby and MongoDB use **metadata.yaml**. For more information read about [cloud init](https://cloudinit.readthedocs.io/en/latest/reference/examples.html).

**metadata.yaml**:

```yaml
#cloud-config
users:
  - name: admiral
    groups: sudo
    shell: /bin/bash
    sudo: 'ALL=(ALL) NOPASSWD:ALL'
    ssh-authorized-keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCWBMo37IsVyvy0aT8FMO7NiFPIxfrUCyp5BA4b4Pr69BahfFuTgHLzkmPz9N0DE7EAHgjTV0QSLAYHWrmJG/8H8K/x9kz9sIK03jySSib+hIpnMdtt4+rC6AiQI9lmYyXeaZPwAaZe+KOozNJvzutRd31vrFJ3VZUQ2rMgNC2x0SyF1kEle/zEwkNMW4E0ea07u6MXrv5aSGyFNakiqpxVO12MQE/UocgiloHurcWP4CSCygdjLre031LwQ80xIIbSslyYG/g8W6DVexOBMyJ5tbw+C0SETBb6d4pA1slrALybQOgD/DWaPtV2aiZJl5ch8GtdjqBtCc2JO9+uJzM3 rsa-key-20230411

runcmd:
 - apt update
 - NEEDRESTART_MODE=a apt install --assume-yes ruby-full ruby-bundler build-essential 
 - NEEDRESTART_MODE=a apt install --assume-yes gnupg curl
 - curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
 - echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-7.0.list
 - apt update
 - DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt install --assume-yes mongodb-org
 - systemctl start mongod
 - systemctl enable mongod

```

**NEEDRESTART_MODE=a** uses for disabling dialog during installation.
![Restart services](./img/Screenshot_1.jpg)
**DEBIAN_FRONTEND=noninteractive** is for disabling other questions during installation.

#### Check installed apps

```bash
admiral@fhm6onfqbmmu8049fbm7:~$ ruby -v
ruby 3.0.2p107 (2021-07-07 revision 0db68f0233) [x86_64-linux-gnu]
admiral@fhm6onfqbmmu8049fbm7:~$ bundler -v
Bundler version 2.3.5
admiral@fhm6onfqbmmu8049fbm7:~$ systemctl status mongod
● mongod.service - MongoDB Database Server
     Loaded: loaded (/lib/systemd/system/mongod.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2023-11-05 10:47:53 UTC; 1min 58s ago
       Docs: https://docs.mongodb.org/manual
   Main PID: 4063 (mongod)
     Memory: 112.7M
        CPU: 1.431s
     CGroup: /system.slice/mongod.service
             └─4063 /usr/bin/mongod --config /etc/mongod.conf

```

### Deploy test app
