#!/bin/sh -eux

# Remove development and kernel source packages
sudo yum -y remove gcc cpp kernel-devel kernel-headers perl;
sudo yum -y clean all;

# Clean up network interface persistence
sudo rm -f /etc/udev/rules.d/70-persistent-net.rules;

for ndev in `sudo ls -1 /etc/sysconfig/network-scripts/ifcfg-*`; do
    if [ "`basename $ndev`" != "ifcfg-lo" ]; then
        sudo sed -i '/^HWADDR/d' "$ndev";
        sudo sed -i '/^UUID/d' "$ndev";
    fi
done

sudo rm -f VBoxGuestAdditions_*.iso VBoxGuestAdditions_*.iso.?;
