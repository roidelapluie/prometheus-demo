#!/bin/bash
set -xe
export VERSION=0.15.2

yum install -y wget
wget https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.linux-amd64.tar.gz -O /tmp/node_exporter.tar.gz
tar -C /opt -xvf /tmp/node_exporter.tar.gz
mv /opt/node_exporter-${VERSION}.linux-amd64 /opt/node_exporter

cat << END > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter

[Service]
ExecStart=/opt/node_exporter/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
END


systemctl enable node_exporter
systemctl start node_exporter
