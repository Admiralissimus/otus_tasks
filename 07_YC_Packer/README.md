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

Create a JSON file **ubuntu.json**.

```json
{
  "builders": [
    {
      "type":      "yandex",
      "token":     none,
      "folder_id": "<folder_ID>",
      "zone":      "ru-central1-a",

      "image_name":        "debian-11-nginx-{{isotime | clean_resource_name}}",
      "image_family":      "debian-web-server",
      "image_description": "my custom debian with nginx",

      "source_image_family": "debian-11",
      "subnet_id":           "<subnet_ID>",
      "use_ipv4_nat":        true,
      "disk_type":           "network-ssd",
      "ssh_username":        "debian"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "inline": [
        "echo 'updating APT'",
        "sudo apt-get update -y",
        "sudo apt-get install -y nginx",
        "sudo su -",
        "sudo systemctl enable nginx.service",
        "curl localhost"
      ]
    }
  ]
}
```

Yandex token will be used by environment variable **YC_TOKEN**.
