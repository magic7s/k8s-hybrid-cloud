// Configure AWS EKS Cluster

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = "${var.EKS_name}"
  subnets      = "${module.vpc.public_subnets}"

  tags               = "${map("Environment", "test")}"
  vpc_id             = "${module.vpc.vpc_id}"
  worker_groups      = "${var.EKS_worker_groups}"
  worker_group_count = "1"
}

resource "aws_security_group_rule" "allow_all_GCP" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "all"
  cidr_blocks = ["${var.GCP_vpc_subnet}", "${var.GKE_cluster_ip}"]
  description = "Worker to Worker"

  security_group_id = "${module.eks.worker_security_group_id}"
}
