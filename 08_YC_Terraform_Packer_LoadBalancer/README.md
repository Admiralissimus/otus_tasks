# 08 YC Terraform Packer LoadBalancer

## Create load balancer and 2 instances using terraform

### 1. Create 2 different images

Create 2 images with small change (I changed main page a little bit) using 07_YC task.

```bash
$ cd 07_YC_Packer_immutable_baked
$ packer build ubuntu.json

....

==> Builds finished. The artifacts of successful builds are:
--> yandex: A disk image was created: my-ubuntu-1604-1699377852 (id: fd8vbfopbn5slc6lrmdd) with family name 
```

Commit some change in repo and make the second image.

```bash
$ cd 07_YC_Packer_immutable_baked
$ packer build ubuntu.json

....

==> Builds finished. The artifacts of successful builds are:
--> yandex: A disk image was created: my-ubuntu-1604-1699380360 (id: fd8taktntenhsiboe8jb) with family name 
```
