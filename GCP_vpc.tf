// Configure new vpc and subnet for GCP

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

resource "google_compute_firewall" "aws-vpn-networks" {
  name              = "aws-vpn-networks"
  network           = "${module.gcp-vpc.self_link}"
  source_ranges     = ["${var.AWS_vpc_subnet}"]
  allow             {
                    protocol = "all"
  }
}
