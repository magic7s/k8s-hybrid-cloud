// Configure AWS VPC, Subnets, and Routes

variable AWS_vpc_name {}
variable AWS_vpc_subnet {}
variable AWS_azs { type = "list" }
variable AWS_public_subnets { type = "list" }

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${ var.AWS_vpc_name }"
  cidr = "${ var.AWS_vpc_subnet }"

  azs             = "${ var.AWS_azs }"
  public_subnets  = "${ var.AWS_public_subnets }"

  enable_nat_gateway = false
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}