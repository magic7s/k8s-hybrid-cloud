terraform {
  backend "s3" {
    bucket = "magic7s"
    key    = "terraform/hybrid-cloud.tfstate"
    region = "us-west-2"
  }
}