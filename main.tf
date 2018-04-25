variable "domain" {}
variable "datacenter" {}
variable "backup_datacenter" {}
variable "do_dns_token" {}
variable "do_ro_token" {}

variable "simple_nodes_count" {
  default = 2
}

variable "apache_nodes_count" {
  default = 2
}

provider "digitalocean" {}

provider "digitalocean" {
  alias = "dns"
  token = "${var.do_dns_token}"
}
