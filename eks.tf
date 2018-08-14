// Configure AWS EKS Cluster

variable AWS_region {}

provider "aws" {
  region   = "${var.AWS_region}"
}

module "eks" {
  source                = "terraform-aws-modules/eks/aws"
  cluster_name          = "test-eks-cluster"
  subnets               = ["subnet-66e2cc2e", "subnet-825658e4"]
  tags                  = "${map("Environment", "test")}"
  vpc_id                = "vpc-586ba233"
}