
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
  --memory 1 \
  --ssh-key ~/test_key.pub
```

User name will be **yc-user**.

```output
done (35s)
id: fhmts2nc7bi1j954qafm
folder_id: b1g6mmcu4pmqf10ge9g2
created_at: "2023-11-04T18:40:58Z"
name: test-preemptible-instance
zone_id: ru-central1-a
platform_id: standard-v2
resources:
  memory: "2147483648"
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
  device_name: fhmolkc2l23edh20lsgd
  auto_delete: true
  disk_id: fhmolkc2l23edh20lsgd
network_interfaces:
  - index: "0"
    mac_address: d0:0d:1d:e0:ae:c3
    subnet_id: e9b6ppr3mbccdlbnvge7
    primary_v4_address:
      address: 10.128.0.20
      one_to_one_nat:
        address: 51.250.94.103
        ip_version: IPV4
gpu_settings: {}
fqdn: fhmts2nc7bi1j954qafm.auto.internal
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
runcmd:
 - apt update
 - NEEDRESTART_MODE=a apt install --assume-yes ruby-full ruby-bundler build-essential 
 - NEEDRESTART_MODE=a apt install --assume-yes gnupg curl
 - curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
 - echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" >> /etc/apt/sources.list.d/mongodb-org-7.0.list
 - apt update
 - NEEDRESTART_MODE=a apt install --assume-yes mongodb-
 - systemctl start mongod
 - systemctl enable mongod
```

**NEEDRESTART_MODE=a** uses for disabling dialog during installation.
![Restart services](./img/Screenshot_1.jpg)

### Deploy test app
