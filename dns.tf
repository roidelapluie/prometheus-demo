resource "digitalocean_domain" "default" {
  provider   = "digitalocean.dns"
  name       = "${var.domain}"
  ip_address = "${digitalocean_droplet.prometheus.ipv4_address}"
}
