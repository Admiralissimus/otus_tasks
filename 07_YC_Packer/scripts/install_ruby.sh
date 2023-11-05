#!/bin/bash
set -e

# Install ruby
apt-get update
NEEDRESTART_MODE=a apt-get install --assume-yes ruby-full ruby-bundler build-essential 