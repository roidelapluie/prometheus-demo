#!/bin/bash
set -xe
export VERSION=0.2.4

yum install -y wget unzip httpd
wget https://github.com/fstab/grok_exporter/releases/download/v${VERSION}/grok_exporter-${VERSION}.linux-amd64.zip -O /tmp/grok_exporter.zip
(cd /opt; unzip /tmp/grok_exporter.zip)
mv /opt/grok_exporter-${VERSION}.linux-amd64 /opt/grok_exporter

cat << END > /etc/grok_exporter.yml
global:
    config_version: 2
input:
    type: file
    path: /var/log/httpd/access_log
    readall: false
grok:
    patterns_dir: ./patterns
metrics:
    - type: counter
      name: apache_http_requests_total
      help: Total number of requests
      match: '%{COMMONAPACHELOG}'
      labels:
          method: '{{.verb}}'
          code: '{{.response}}'
server:
    host: 0.0.0.0
    port: 9144
END

cat << END > /etc/systemd/system/grok_exporter.service
[Unit]
Description=Grok Exporter

[Service]
WorkingDirectory=/opt/grok_exporter
ExecStart=/opt/grok_exporter/grok_exporter --config /etc/grok_exporter.yml
Restart=always

[Install]
WantedBy=multi-user.target
END


mkdir /var/www/html/test
echo "hello" >> /var/www/html/test/index.html

systemctl enable grok_exporter
systemctl start grok_exporter
systemctl start httpd
systemctl enable httpd
