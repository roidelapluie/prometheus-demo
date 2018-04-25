data "template_file" "prometheus" {
  template = "${file("prometheus.tpl")}"

  vars {
    domain = "${var.domain}"
  }
}

data "template_file" "doctl" {
  template = "${file("doctl.tpl")}"

  vars {
    ro_token = "${var.do_ro_token}"
  }
}

data "template_file" "blackbox" {
  template = "${file("blackbox.tpl")}"

  vars {
    domain = "${var.domain}"
  }
}

resource "digitalocean_droplet" "prometheus" {
  image    = "centos-7-x64"
  name     = "prometheus"
  region   = "${var.datacenter}"
  size     = "512mb"
  ssh_keys = ["${digitalocean_ssh_key.tf.id}"]

  provisioner "file" {
    connection {
      user        = "root"
      private_key = "${file("id_rsa")}"
    }

    content     = "${data.template_file.prometheus.rendered}"
    destination = "/etc/prometheus.yml"
  }

  provisioner "file" {
    connection {
      user        = "root"
      private_key = "${file("id_rsa")}"
    }

    content     = "${data.template_file.doctl.rendered}"
    destination = "/etc/doctl"
  }

  provisioner "file" {
    connection {
      user        = "root"
      private_key = "${file("id_rsa")}"
    }

    content     = "${data.template_file.blackbox.rendered}"
    destination = "/etc/blackbox.yml"
  }

  provisioner "remote-exec" {
    connection {
      user        = "root"
      private_key = "${file("id_rsa")}"
    }

    scripts = [
      "install-prometheus.sh",
      "install-node_exporter.sh",
      "install-blackbox.sh",
      "install-doctl.sh",
    ]
  }
}

resource "digitalocean_record" "prometheus" {
  provider = "digitalocean.dns"
  domain   = "${digitalocean_domain.default.name}"
  type     = "A"
  name     = "prometheus"
  value    = "${digitalocean_droplet.prometheus.ipv4_address}"
  ttl      = 30
}

resource "digitalocean_record" "prometheus_node" {
  provider = "digitalocean.dns"
  domain   = "${digitalocean_domain.default.name}"
  type     = "A"
  name     = "node"
  value    = "${digitalocean_droplet.prometheus.ipv4_address}"
  ttl      = 30
}
