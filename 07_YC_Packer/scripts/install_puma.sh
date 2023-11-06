#!/bin/bash
set -e
apt-get update
apt-get install -y git
useradd -m -U -d /var/puma puma
cd /var/puma
git clone -b monolith https://github.com/admiralissimus/reddit.git
cd reddit && bundle install
systemctl start puma
systemctl enable puma