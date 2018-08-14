data "external" "myipaddr" {
  program = ["bash", "-c", "printf '{\\\"ip\\\" : \\\"%s\\\" }' `dig myip.opendns.com @resolver1.opendns.com +short`"]
}

