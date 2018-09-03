// Configure AWS EKS Cluster

module "eks" {
  source                = "terraform-aws-modules/eks/aws"
  cluster_name          = "test-eks-cluster"
  subnets               = "${module.vpc.public_subnets}"

  tags                  = "${map("Environment", "test")}"
  vpc_id                = "${module.vpc.vpc_id}"
  worker_groups         = "${var.AWS_worker_groups}"
  worker_group_count    = "1"
}