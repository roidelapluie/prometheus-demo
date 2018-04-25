#!/bin/bash
set -xe
export VERSION=2.2.1

yum install -y wget
wget https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-amd64.tar.gz -O /tmp/prometheus.tar.gz
tar -C /opt -xvf /tmp/prometheus.tar.gz
mv /opt/prometheus-${VERSION}.linux-amd64 /opt/prometheus

useradd prometheus
mkdir /var/lib/prometheus
chown prometheus: /var/lib/prometheus



cat << END > /etc/systemd/system/prometheus.service
[Unit]

[Service]
ExecStart=/opt/prometheus/prometheus \
          --config.file=/etc/prometheus.yml \
          --storage.tsdb.retention=4d \
          --storage.tsdb.path=/var/lib/prometheus
User=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
END


systemctl enable prometheus
systemctl start prometheus
