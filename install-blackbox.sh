#!/bin/bash
set -xe
export VERSION=0.10.0

yum install -y wget
wget https://github.com/prometheus/blackbox_exporter/releases/download/v${VERSION}/blackbox_exporter-${VERSION}.linux-amd64.tar.gz -O /tmp/blackbox_exporter.tar.gz
tar -C /opt -xvf /tmp/blackbox_exporter.tar.gz
mv /opt/blackbox_exporter-${VERSION}.linux-amd64 /opt/blackbox_exporter
chmod +x /opt/blackbox_exporter/blackbox_exporter

cat << END > /etc/systemd/system/blackbox_exporter.service
[Unit]
Description=Blackbox Exporter

[Service]
ExecStart=/opt/blackbox_exporter/blackbox_exporter --config.file /etc/blackbox.yml
Restart=always

[Install]
WantedBy=multi-user.target
END


systemctl enable blackbox_exporter
systemctl start blackbox_exporter
