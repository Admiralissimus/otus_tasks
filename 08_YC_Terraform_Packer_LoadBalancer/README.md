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

```
