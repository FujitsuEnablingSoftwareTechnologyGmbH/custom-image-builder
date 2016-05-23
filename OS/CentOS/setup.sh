#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

sudo tee /usr/lib/systemd/system/docker-bootstrap.service <<-'EOF'
[Unit]
Description=Start the bootstrap Docker daemon

[Service]
ExecStart=/bin/docker daemon \
        -H unix:///var/run/docker-bootstrap.sock \
        -p /var/run/docker-bootstrap.pid \
        --iptables=false \
        --ip-masq=false \
        --bridge=none \
        --graph=/var/lib/docker-bootstrap

[Install]
WantedBy=multi-user.target
EOF

sudo yum install -y docker-engine

sudo systemctl enable docker
sudo systemctl restart docker

sudo systemctl enable docker-bootstrap
sudo systemctl restart docker-bootstrap

# install bridge-utils if not already installed
rpm -qa | grep -qw bridge-utils || sudo yum -y install bridge-utils
