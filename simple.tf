resource "digitalocean_droplet" "prometheus_node" {
  image    = "centos-7-x64"
  count    = "${var.simple_nodes_count}"
  name     = "${format("prometheus-node-%03d", count.index + 1)}"
  region   = "${var.datacenter}"
  size     = "512mb"
  ssh_keys = ["${digitalocean_ssh_key.tf.id}"]

  provisioner "remote-exec" {
    connection {
      user        = "root"
      private_key = "${file("id_rsa")}"
    }

    scripts = [
      "install-node_exporter.sh",
    ]
  }
}

resource "digitalocean_record" "prometheus_simple_node" {
  count    = "${var.simple_nodes_count}"
  provider = "digitalocean.dns"
  domain   = "${digitalocean_domain.default.name}"
  type     = "A"
  name     = "node"
  value    = "${element(digitalocean_droplet.prometheus_node.*.ipv4_address, count.index)}"
  ttl      = 30
}
