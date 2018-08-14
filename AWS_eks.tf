// Configure AWS EKS Cluster

variable AWS_region {}
variable AWS_worker_groups {type = "list"}

provider "aws" {
  region   = "${var.AWS_region}"
}

module "eks" {
  source                = "terraform-aws-modules/eks/aws"
  cluster_name          = "test-eks-cluster"
  subnets               = ["subnet-5d6ba236", "subnet-5e6ba235", "subnet-5f6ba234"]
  tags                  = "${map("Environment", "test")}"
  vpc_id                = "vpc-586ba233"
  worker_groups         = "${var.AWS_worker_groups}"
  worker_group_count    = "1"
  #workstation_cidr      = "${data.external.myipaddr.result["ip"]}/32"
}