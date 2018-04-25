resource "digitalocean_droplet" "prometheus_apache" {
  image    = "centos-7-x64"
  count    = "${var.apache_nodes_count}"
  name     = "${format("www%03d", count.index + 1)}"
  region   = "${count.index % 2 == 0 ? var.datacenter : var.backup_datacenter}"
  size     = "512mb"
  ssh_keys = ["${digitalocean_ssh_key.tf.id}"]

  provisioner "remote-exec" {
    connection {
      user        = "root"
      private_key = "${file("id_rsa")}"
    }

    scripts = [
      "install-node_exporter.sh",
      "install-apache.sh",
    ]
  }
}

resource "digitalocean_record" "prometheus_www00" {
  count    = "${var.apache_nodes_count}"
  provider = "digitalocean.dns"
  domain   = "${digitalocean_domain.default.name}"
  type     = "A"
  name     = "${format("www%03d", count.index + 1)}"
  value    = "${digitalocean_droplet.prometheus_apache.*.ipv4_address[count.index]}"
  ttl      = 30
}

resource "digitalocean_record" "prometheus_www" {
  count    = "${var.apache_nodes_count}"
  provider = "digitalocean.dns"
  domain   = "${digitalocean_domain.default.name}"
  type     = "A"
  name     = "www"
  value    = "${digitalocean_droplet.prometheus_apache.*.ipv4_address[count.index]}"
  ttl      = 30
}
