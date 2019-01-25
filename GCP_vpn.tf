//  GCP VPN Configuration

resource "google_compute_address" "gcp-vpn-ip" {
  name = "gcp-vpn-ip"
}

resource "google_compute_vpn_gateway" "gcp-vpn-gw" {
  name    = "gcp-vpn-gw"
  network = "${module.gcp-vpc.self_link}"
}

resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = "${google_compute_address.gcp-vpn-ip.address}"
  target      = "${google_compute_vpn_gateway.gcp-vpn-gw.self_link}"
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500-500"
  ip_address  = "${google_compute_address.gcp-vpn-ip.address}"
  target      = "${google_compute_vpn_gateway.gcp-vpn-gw.self_link}"
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500-4500"
  ip_address  = "${google_compute_address.gcp-vpn-ip.address}"
  target      = "${google_compute_vpn_gateway.gcp-vpn-gw.self_link}"
}

/*
 * ----------VPN Tunnel1----------
 */

resource "google_compute_vpn_tunnel" "gcp-tunnel1" {
  name          = "gcp-tunnel1"
  peer_ip       = "${aws_vpn_connection.preshared.tunnel1_address}"
  shared_secret = "${aws_vpn_connection.preshared.tunnel1_preshared_key}"
  ike_version   = 1

  target_vpn_gateway      = "${google_compute_vpn_gateway.gcp-vpn-gw.self_link}"
  local_traffic_selector  = ["${var.GCP_vpc_subnet}"]
  remote_traffic_selector = ["${var.AWS_vpc_subnet}"]

  #router = "${google_compute_router.gcp-router1.name}"

  depends_on = [
    "google_compute_forwarding_rule.fr_esp",
    "google_compute_forwarding_rule.fr_udp500",
    "google_compute_forwarding_rule.fr_udp4500",
  ]
}

resource "google_compute_vpn_tunnel" "gcp-tunnel2" {
  name          = "gcp-tunnel2"
  peer_ip       = "${aws_vpn_connection.preshared.tunnel2_address}"
  shared_secret = "${aws_vpn_connection.preshared.tunnel2_preshared_key}"
  ike_version   = 1

  target_vpn_gateway      = "${google_compute_vpn_gateway.gcp-vpn-gw.self_link}"
  local_traffic_selector  = ["${var.GCP_vpc_subnet}"]
  remote_traffic_selector = ["${var.AWS_vpc_subnet}"]

  #router = "${google_compute_router.gcp-router1.name}"

  depends_on = [
    "google_compute_forwarding_rule.fr_esp",
    "google_compute_forwarding_rule.fr_udp500",
    "google_compute_forwarding_rule.fr_udp4500",
  ]
}

resource "google_compute_router" "gcp-router1" {
  name    = "gcp-router1"
  region  = "${var.GCP_region}"
  network = "${module.gcp-vpc.self_link}"

  bgp {
    asn = "${aws_customer_gateway.main.bgp_asn}"
  }
}

resource "google_compute_route" "aws1" {
  name                = "aws-route1"
  dest_range          = "${var.AWS_vpc_subnet}"
  network             = "${module.gcp-vpc.self_link}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.gcp-tunnel1.self_link}"
  priority            = 100
}

resource "google_compute_route" "aws2" {
  name                = "aws-route2"
  dest_range          = "${var.AWS_vpc_subnet}"
  network             = "${module.gcp-vpc.self_link}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.gcp-tunnel2.self_link}"
  priority            = 200
}
