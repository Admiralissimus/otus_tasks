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


# 1  apt-get update
# 2  apt-get install --assume-yes ruby-full ruby-bundler build-essential
# 3  apt-get install git
# 4  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D68FA50FEA312927
# 5  echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list
# 6  apt-get update
# 7  apt-get install -y mongodb-org
# 8  systemctl enable mongod
# 9  systemctl start mongod

# 2  git clone -b monolith https://github.com/admiralissimus/reddit.git
# 3  cd reddit && bundle install
# 4  puma -d
# 5  ps aux | grep puma
