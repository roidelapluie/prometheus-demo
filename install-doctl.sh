#!/bin/bash
set -xe
export VERSION=1.8.0

yum install -y wget
wget https://github.com/digitalocean/doctl/releases/download/v${VERSION}/doctl-${VERSION}-linux-amd64.tar.gz -O /tmp/doctl.tar.gz
tar -C /opt -xvf /tmp/doctl.tar.gz

cat << END > /opt/doctl-prometheus
#!/bin/bash
set -e
set -o pipefail
/opt/doctl compute droplet list --no-header --format Name,PublicIPv4,Region,Status > /tmp/doctl

cat /tmp/doctl|
awk '\$4 == "active" && \$1 ~ /www/ { print "- targets:";print"  - "\$2":9144";print"  labels:";print "    region: "\$3;print "    instance: "\$1  }'|
tee /etc/prometheus-www.yml.tmp
mv /etc/prometheus-www.yml.tmp /etc/prometheus-www.yml
cat /tmp/doctl|
awk '\$4 == "active" { print "- targets:";print"  - "\$2":9100";print"  labels:";print "    region: "\$3;print "    instance: "\$1  }'|
tee /etc/prometheus-do.yml.tmp
mv /etc/prometheus-do.yml.tmp /etc/prometheus-do.yml
END
chmod +x /opt/doctl-prometheus

cat << END > /etc/systemd/system/doctl.service
[Unit]
Description=Blackbox Exporter

[Service]
Type=oneshot
EnvironmentFile=/etc/doctl
ExecStart=/opt/doctl-prometheus

[Install]
WantedBy=multi-user.target
END
cat << END > /etc/systemd/system/doctl.timer
[Unit]
Description=Blackbox Exporter

[Timer]
OnCalendar=*:*:0/10

[Install]
WantedBy=multi-user.target
END


systemctl enable doctl.timer
systemctl start doctl.timer
