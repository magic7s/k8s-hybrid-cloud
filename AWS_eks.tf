// Configure AWS EKS Cluster

variable AWS_region {}
variable AWS_worker_groups {type = "list"}

provider "aws" {
  region   = "${var.AWS_region}"
}

module "eks" {
  source                = "terraform-aws-modules/eks/aws"
  cluster_name          = "test-eks-cluster"
  subnets               = "${module.vpc.public_subnets}"

  tags                  = "${map("Environment", "test")}"
  vpc_id                = "${module.vpc.vpc_id}"
  worker_groups         = "${var.AWS_worker_groups}"
  worker_group_count    = "1"
}