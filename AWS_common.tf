// Common configurations for AWS
variable AWS_region {}
variable AWS_worker_groups {type = "list"}
variable AWS_vpc_name {}
variable AWS_vpc_subnet {}
variable AWS_azs { type = "list" }
variable AWS_public_subnets { type = "list" }

provider "aws" {
  region   = "${var.AWS_region}"
}

