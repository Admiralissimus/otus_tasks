#!/bin/bash
set -e
apt-get update
apt-get install -y git
useradd -m -U -d /var/puma puma
cd /var/puma
git clone -b monolith https://github.com/admiralissimus/reddit.git
cd reddit 
bundle install
chown -R puma:puma /var/puma
mv /tmp/puma.service /etc/systemd/system/puma.service 
chown root:root /etc/systemd/system/puma.service
systemctl start puma
systemctl enable puma