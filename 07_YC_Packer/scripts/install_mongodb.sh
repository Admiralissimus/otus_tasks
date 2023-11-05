#!/bin/bash
set -e

# Install MongoDB
apt-get update
NEEDRESTART_MODE=a apt-get install --assume-yes gnupg curl
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" > /etc/apt/sources.list.d/mongodb-org-7.0.list
apt-get update
DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt-get install --assume-yes mongodb-org
systemctl start mongod
systemctl enable mongod
