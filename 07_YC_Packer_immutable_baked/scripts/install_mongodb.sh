#!/bin/bash
set -e

# Install MongoDB
apt-get update
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D68FA50FEA312927
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list
apt-get update
apt-get install --assume-yes mongodb-org
systemctl start mongod
systemctl enable mongod
