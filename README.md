# Kubernetes Hybrid Cloud
## Building a hybrid cloud with Kubernetes and Terraform

_Requirements_
* Must have AWS kubectl available in PATH
* Must have AWS aws-iam-authenticator available in PATH
* Must have gcloud cli available in PATH
* Must have helm available in PATH
* Must install custom terrafrom plugin from https://github.com/mcuadros/terraform-provider-helm


_Resources_ - *This project makes use of many others contributions.*
* https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/1.6.0
* https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/1.41.0
* https://registry.terraform.io/modules/terraform-aws-modules/vpn-gateway/aws/1.4.0 (code use)
* https://registry.terraform.io/modules/tasdikrahman/network/google/0.1.1
* https://registry.terraform.io/modules/tasdikrahman/network-subnet/google/0.1.1
* https://github.com/mariopoeta/terraform-google-cloudvpn-withoutbgp (code use)
* https://github.com/mcuadros/terraform-provider-helm