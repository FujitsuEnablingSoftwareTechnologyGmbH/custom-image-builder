# k8-nodeOS-builder

## Prepere Openstack

Go to
<https://github.com/FujitsuEnablingSoftwareTechnologyGmbH/devstack-vagrant>

Clone and run Openstack in Vagrand

### Upload reference image via glance

```
cd devstack-vagrant
vagrant ssh

sudo su - stack
. devstack/openrc admin admin

curl -L http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1603.qcow2.xz -O
unxz CentOS-7-x86_64-GenericCloud-1603.qcow2.xz
glance image-create --name centos7 --disk-format qcow2 --container-format bare --file CentOS-7-x86_64-GenericCloud-1603.qcow2 --is-public True

exit
```


### Openstack network configuration
Packer requires well configured network to be able proceed all build steps.
In file install.json you have to enter private network ID.
Private network should be connected via router to public network.



## Install Packer
Packer is a tool developed by HashiCorp (the people behind Vagrant) to help you create identical cloud images for a variety of different environments. It also allows you to create image templates that are easy to version control and understand what happens during the image creation process.

download  from here: <https://www.packer.io/downloads.html> and unzip
```
curl -L https://releases.hashicorp.com/packer/0.10.0/packer_0.10.0_linux_amd64.zip -O
unzip packer_0.10.0_linux_amd64.zip
```

You can do it in this project or in your home directory and copy packer binary to custom-image-builder

## Run build process

First open install.json file and make some simple modifications
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
    "image_name": "centos7-docker-full",
    "source_image": "e842d5ee-3c59-4283-86bc-067ff433bc07",
    "flavor": "m1.small",
    "networks": ["c3c8c432-3f2b-49a8-9281-a190d6a932ff"],
    "insecure": "true",
    "use_floating_ip": true,
    "ssh_pty" : true
  }

  ],

  "provisioners": [{
    "type": "shell",
    "script": "install-docker.sh"
  },
  {
      "type": "shell",
      "script": "install-docker-bootstrap.sh"
  }]
}
```
"image_name": "centos7-docker-full" - name for new image

"source_image": "e842d5ee-3c59-4283-86bc-067ff433bc07" - source image ID. You can get it from Horizon

"networks": ["c3c8c432-3f2b-49a8-9281-a190d6a932ff"] - Openstack private network ID. You can get it from Horizon

When you update source_image and networks you must source Openstack credential variables from
openrc-default.sh

```
#!/bin/bash

export OS_IDENTITY_API_VERSION=2.0
export OS_USERNAME=admin
export OS_PASSWORD=secretsecret
export OS_AUTH_URL=http://192.168.123.100:5000/v2.0
export OS_TENANT_NAME=admin
export OS_TENANT_ID=0f3f383e84d24d618d3c8f9b2ccc8e20

```
Enter correct OS_TENANT_ID from Horizon: Identity -> Projects -> admin -> Project ID


Source the openrc-default.sh

```
. openrc-default.sh
```



To run build process execute command:
```
./packer build install.json
```
You shuld see:
```
openstack output will be in this color.

==> openstack: Discovering enabled extensions...
==> openstack: Loading flavor: m1.small
    openstack: Verified flavor. ID: 2
==> openstack: Creating temporary keypair: packer 57075932-4c1f-70cb-a731-5831535e26bf ...
==> openstack: Created temporary keypair: packer 57075932-4c1f-70cb-a731-5831535e26bf
==> openstack: Launching server...
    openstack: Server ID: fc236485-758a-474e-b354-84b08d18f6aa
==> openstack: Waiting for server to become ready...
==> openstack: Creating floating IP...
    openstack: Pool: public
    openstack: Created floating IP: 172.24.4.13
==> openstack: Associating floating IP with server...
    openstack: IP: 172.24.4.13
    openstack: Added floating IP 172.24.4.13 to instance!
==> openstack: Waiting for SSH to become available...
==> openstack: Connected to SSH!
==> openstack: Provisioning with shell script: install-docker.sh
    openstack: [dockerrepo]
    openstack: name=Docker Repository
    openstack: baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
    openstack: enabled=1
    openstack: gpgcheck=1
    openstack: gpgkey=https://yum.dockerproject.org/gpg
    openstack: Loaded plugins: fastestmirror
    openstack: base             | 3.6 kB     00:00
    openstack: dockerrepo       | 2.9 kB     00:00
    openstack: extras           | 3.4 kB     00:00
    openstack: updates          | 3.4 kB     00:00
    openstack: (1/5): extras/7/x8 | 117 kB   00:00
    openstack: (2/5): base/7/x86_ | 155 kB   00:00
    openstack: (3/5): updates/7/x | 3.9 MB   00:00
    openstack: (4/5): dockerrepo/ |  13 kB   00:00
    openstack: (5/5): base/7/x86_ | 5.3 MB   00:02
    openstack: Determining fastest mirrors
    openstack: * base: ftp.icm.edu.pl
    openstack: * extras: ftp.icm.edu.pl
    openstack: * updates: mirror.onet.pl
    openstack: Resolving Dependencies
    openstack: --> Running transaction check
    openstack: ---> Package docker-engine.x86_64 0:1.10.3-1.el7.centos will be installed
    openstack: --> Processing Dependency: docker-engine-selinux >= 1.10.3-1.el7.centos for package: docker-engine-1.10.3-1.el7.centos.x86_64
    openstack: --> Running transaction check
    openstack: ---> Package docker-engine-selinux.noarch 0:1.10.3-1.el7.centos will be installed
    openstack: --> Finished Dependency Resolution
    openstack:
    openstack: Dependencies Resolved
    openstack:
    openstack: ========================================
    openstack: Package
    openstack: Arch   Version Repository  Size
    openstack: ========================================
    openstack: Installing:
    openstack: docker-engine
    openstack: x86_64 1.10.3-1.el7.centos
    openstack: dockerrepo 9.6 M
    openstack: Installing for dependencies:
    openstack: docker-engine-selinux
    openstack: noarch 1.10.3-1.el7.centos
    openstack: dockerrepo  28 k
    openstack:
    openstack: Transaction Summary
    openstack: ========================================
    openstack: Install  1 Package (+1 Dependent package)
    openstack:
    openstack: Total download size: 9.6 M
    openstack: Installed size: 41 M
    openstack: Downloading packages:
    openstack: warning: /var/cache/yum/x86_64/7/dockerrepo/packages/docker-engine-selinux-1.10.3-1.el7.centos.noarch.rpm: Header V4 RSA/SHA512 Signature, key ID 2c52609d: NOKEY
    openstack: Public key for docker-engine-selinux-1.10.3-1.el7.centos.noarch.rpm is not installed
    openstack: (1/2): docker-engi |  28 kB   00:00
    openstack: (2/2): docker-engi | 9.6 MB   00:01
    openstack: ----------------------------------------
    openstack: Total      5.3 MB/s | 9.6 MB  00:01
    openstack: Retrieving key from https://yum.dockerproject.org/gpg
    openstack: Importing GPG key 0x2C52609D:
    openstack: Userid     : "Docker Release Tool (releasedocker) <docker@docker.com>"
    openstack: Fingerprint: 5811 8e89 f3a9 1289 7c07 0adb f762 2157 2c52 609d
    openstack: From       : https://yum.dockerproject.org/gpg
    openstack: Running transaction check
    openstack: Running transaction test
    openstack: Transaction test succeeded
    openstack: Running transaction
    openstack:   Installing : docker-engine-seli   1/2
    openstack:   Installing : docker-engine-1.10   2/2
    openstack: Verifying  : docker-engine-seli   1/2
    openstack: Verifying  : docker-engine-1.10   2/2
    openstack:
    openstack: Installed:
    openstack: docker-engine.x86_64 0:1.10.3-1.el7.centos
    openstack:
    openstack: Dependency Installed:
    openstack: docker-engine-selinux.noarch 0:1.10.3-1.el7.centos
    openstack:
    openstack: Complete!
    openstack: Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /usr/lib/systemd/system/docker.service.
==> openstack: Provisioning with shell script: install-docker-bootstrap.sh
    openstack: [Unit]
    openstack: Description=Start the bootstrap Docker daemon
    openstack:
    openstack: [Service]
    openstack: ExecStart=/bin/docker daemon \
    openstack: -H unix:///var/run/docker-bootstrap.sock \
    openstack: -p /var/run/docker-bootstrap.pid \
    openstack: --iptables=false \
    openstack: --ip-masq=false \
    openstack: --bridge=none \
    openstack: --graph=/var/lib/docker-bootstrap
    openstack:
    openstack: [Install]
    openstack: WantedBy=multi-user.target
    openstack: Created symlink from /etc/systemd/system/multi-user.target.wants/docker-bootstrap.service to /usr/lib/systemd/system/docker-bootstrap.service.
==> openstack: Stopping server: fc236485-758a-474e-b354-84b08d18f6aa ...
    openstack: Waiting for server to stop: fc236485-758a-474e-b354-84b08d18f6aa ...
==> openstack: Creating the image: centos7-docker-full
    openstack: Image: 8002229f-263a-426c-b696-f86ced26270c
==> openstack: Waiting for image centos7-docker-full (image id: 8002229f-263a-426c-b696-f86ced26270c) to become ready...
==> openstack: Deleted temporary floating IP 172.24.4.13
==> openstack: Terminating the source server: fc236485-758a-474e-b354-84b08d18f6aa ...
==> openstack: Deleting temporary keypair: packer 57075932-4c1f-70cb-a731-5831535e26bf ...
Build 'openstack' finished.

==> Builds finished. The artifacts of successful builds are:
--> openstack: An image was created: 8002229f-263a-426c-b696-f86ced26270c

```

Now image is available in OpenStack with name centos7-docker-full


