# Prometheus Demo


A demo that spins up Linux nodes and Apache frontends next to a prometheus
setup.


Uses digitalocean and terraform.

## Variables

domain: domain name
datacenter: datacenter for the nodes
backup_datacenter: datacenter for half of the apache frontends
do_dns_token: digitalocean api token to create and change domain
do_ro_token: A read only digitalocean api token. Required for nodes discovery of
Prometheus.

## Status

This project is a gigantic hack; do not use it in production.
