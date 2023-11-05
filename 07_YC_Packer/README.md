# 7 YC packer

## 1. Install packer

## 2. Configure packer

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
