#!/bin/bash

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

sudo systemctl enable docker-bootstrap
sudo systemctl restart docker-bootstrap


