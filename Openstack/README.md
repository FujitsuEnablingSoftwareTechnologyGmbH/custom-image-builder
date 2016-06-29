k8-nodeOS-builder
==================

#### Prerequisites
Install [Packer.io](https://packer.io/downloads.html), see [installation instructions](https://packer.io/docs/installation.html).
Enable SSH in your Openstack Security Group. Usually default group is assigned to the nodeos instance. So it requires to add SSH into default security group to enable the connection to the instance. 

#### Edit template file
Open install_nodeos.json file and populate the marked fields with appropriate values:
-	**name** 					*(name that will identify your image file)*
-	**source_image** 	*(Project -> Compute -> Images -> centos7 -> ID)*
-	**networks**			*(Admin -> Networks -> Network Name -> ID)*
```
{
    "builders": [{
        "type": "openstack",
        "identity_endpoint": "http://192.168.123.100:5000/v2.0",
        "tenant_name": "admin",
        "username": "admin",
        "password": "secretsecret",
        "region": "RegionOne",
        "ssh_username": "centos",
        "image_name": "node_OS",
        "source_image": "25fad5d7-6a24-4ac6-9f54-63fe21e0d4db",
        "flavor": "m1.small",
        "networks": [
            "bee186c1-8e4d-4afb-bb33-1fc8e6aaad10"
        ],
        "insecure": "true",
        "use_floating_ip": true,
        "ssh_pty": true
    }],
    "provisioners": [{
        "type": "shell",
        "execute_command": "{{.Vars}} /bin/sh -x '{{.Path}}'",
        "script": "../OS/CentOS/prepare-docker.sh"
    }, {
        "type": "shell",
        "execute_command": "{{.Vars}} /bin/sh -x '{{.Path}}'",
        "script": "../OS/CentOS/minimize-image.sh"
    }]
}
```

#### Validate template file for correctness:
```
$ ./packer validate Openstack/DevStack/install_nodeos.json
```

#### Run build process:
```
$ ./packer build Openstack/DevStack/install_nodeos.json
```
If everything is configured correctly you should see following output:
```
[vagrant@localhost k8s-nodeos-builder]$ ./packer build Openstack/DevStack/install_nodeos.json
openstack output will be in this color.

==> openstack: Discovering enabled extensions...
==> openstack: Loading flavor: m1.small
    openstack: Verified flavor. ID: 2
==> openstack: Creating temporary keypair: packer 5730af03-4f23-d5d5-ecd6-524e0817fbbb ...
==> openstack: Created temporary keypair: packer 5730af03-4f23-d5d5-ecd6-524e0817fbbb
==> openstack: Launching server...
    openstack: Server ID: f1586066-b329-4784-9a1b-6a8d9ffe7969
==> openstack: Waiting for server to become ready...
==> openstack: Creating floating IP...
    openstack: Pool: public
    openstack: Created floating IP: 172.24.4.6
==> openstack: Associating floating IP with server...
    openstack: IP: 172.24.4.6
    openstack: Added floating IP 172.24.4.6 to instance!
==> openstack: Waiting for SSH to become available...
==> openstack: Connected to SSH!
==> openstack: Provisioning with shell script: OS/CentOS/prepare-docker.sh
    openstack: + set -o errexit
    openstack: + set -o nounset
    openstack: + set -o pipefail
--------------------output left out for brevity's sake.-------------------------
    openstack: + sudo yum -y clean all
    openstack: Loaded plugins: fastestmirror
    openstack: Cleaning repos: base dockerrepo extras updates
    openstack: Cleaning up everything
    openstack: Cleaning up list of fastest mirrors
    openstack: + sudo rm -f /etc/udev/rules.d/70-persistent-net.rules
    openstack: ++ sudo ls -1 /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-lo
    openstack: + for ndev in '`sudo ls -1 /etc/sysconfig/network-scripts/ifcfg-*`'
    openstack: ++ basename /etc/sysconfig/network-scripts/ifcfg-eth0
    openstack: + '[' ifcfg-eth0 '!=' ifcfg-lo ']'
    openstack: + sudo sed -i '/^HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth0
    openstack: + sudo sed -i '/^UUID/d' /etc/sysconfig/network-scripts/ifcfg-eth0
    openstack: + for ndev in '`sudo ls -1 /etc/sysconfig/network-scripts/ifcfg-*`'
    openstack: ++ basename /etc/sysconfig/network-scripts/ifcfg-lo
    openstack: + '[' ifcfg-lo '!=' ifcfg-lo ']'
    openstack: + sudo dd if=/dev/zero of=/EMPTY bs=1M
    openstack: dd: error writing ‘/EMPTY’: No space left on device
    openstack: 19507+0 records in
    openstack: 19506+0 records out
    openstack: 20453638144 bytes (20 GB) copied, 155.339 s, 132 MB/s
    openstack: + echo 'dd exit code 1 is suppressed'
    openstack: dd exit code 1 is suppressed
    openstack: + sudo rm -f /EMPTY
    openstack: + sync
==> openstack: Stopping server: f1586066-b329-4784-9a1b-6a8d9ffe7969 ...
    openstack: Waiting for server to stop: f1586066-b329-4784-9a1b-6a8d9ffe7969 ...
==> openstack: Creating the image: centos7-docker-full
    openstack: Image: cf01a239-dd66-4ea4-bea3-c71ace57ddfa
==> openstack: Waiting for image centos7-docker-full (image id: cf01a239-dd66-4ea4-bea3-c71ace57ddfa) to become ready...
==> openstack: Deleted temporary floating IP 172.24.4.6
==> openstack: Terminating the source server: f1586066-b329-4784-9a1b-6a8d9ffe7969 ...
==> openstack: Deleting temporary keypair: packer 5730af03-4f23-d5d5-ecd6-524e0817fbbb ...
Build 'openstack' finished.
```
Image should now be available on OpenStack. You should see it on the dashboard under **Project -> Images**
