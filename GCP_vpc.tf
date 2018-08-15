// Configure new vpc and subnet for GCP

variable GCP_vpc_name {}
variable GCP_subnet_name {}
variable GCP_vpc_subnet {}

module "gcp-vpc" {
  source = "tasdikrahman/network/google"
  name   = "${var.GCP_vpc_name}"
}

module "gcp-subnet1" {
  source            = "tasdikrahman/network-subnet/google"
  name              = "${var.GCP_subnet_name}"
  vpc               = "${module.gcp-vpc.self_link}"
  ip_cidr_range     = "${var.GCP_vpc_subnet}"
}
