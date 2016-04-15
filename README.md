# k8-nodeOS-builder
> tutorial to upload custome OS images to DevStack & CloudStack

## Set-up enviroment for Openstack on CityCloud
We are assuming that CityCloud or whoever your choice of public cloud provider lets you create a reference image. Openstack api to provision images requires you to have a reference image on which the provisioning will be based. After you have successfully created a reference image, in this case a CentOS image, we will be using packer to further costumize the image with needed packages.

- Building on OpenStack on City Cloud requires all the following environment
variables (with example values):

```
export OS_AUTH_URL=https://identity1.citycloud.com:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_DOMAIN_ID=58919a3823e94770989eb67e158f11f5
export OS_PROJECT_DOMAIN_ID=58919a3823e94770989eb67e158f11f5
export OS_USER_DOMAIN_ID=58919a3823e94770989eb67e158f11f5
export OS_TENANT_ID=5e6baffe348448a6b37ddbbed7def0ec
export OS_PROJECT_ID=5e6baffe348448a6b37ddbbed7def0ec
export OS_USERNAME=packer-demo
export OS_PASSWORD=ThePassword
export OS_REGION_NAME=Sto2
```
Open openstack_install.json file and populate the marked fields: name, source_image and networks.
```
{
  "builders": [ 
    {
      "type": "openstack",
      "endpoint_type": "publicURL",
      "ssh_username": "centos",
      "ssh_pty": "true",
      "image_name": "packer-demo-{{timestamp}}",
      "source_image": "01e6ecff-bbcb-4f6e-8b5c-98be62ed995f",
      "flavor": "8e00bc89-f2b0-40d3-96d4-05bd67f6e6bf",
      "use_floating_ip": "true",
      "floating_ip": "37.153.139.206"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "execute_command": "{{.Vars}} /bin/sh -x '{{.Path}}'",
      "script": "scripts/install-docker.sh"
    },
    {
      "type": "shell",
      "execute_command": "{{.Vars}} /bin/sh -x '{{.Path}}'",
      "script": "scripts/install-docker-bootstrap.sh"
    },
    {
      "type": "shell",
      "execute_command": "{{.Vars}} /bin/sh -x '{{.Path}}'",
      "script": "scripts/cleanup.sh"
    },
    {
      "type": "shell",
      "execute_command": "{{.Vars}} /bin/sh -x '{{.Path}}'",
      "script": "scripts/minimize.sh"
    }
  ]
}
```


With the above variables set run: ```packer build -only=openstack cloud.json```


## Set-up enviroment for DevStack
Go to
<https://github.com/FujitsuEnablingSoftwareTechnologyGmbH/devstack-vagrant>

After cloning the repository, follow the steps on how to spin up a DevStack in Vagrand.

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

### Install Packer
Packer is a tool developed by HashiCorp (the people behind Vagrant) to help you create identical cloud images for a variety of different environments. It also allows you to create image templates that are easy to version control and understand what happens during the image creation process.

Downloads for different OS's are available from: <https://www.packer.io/downloads.html>

```
# linux users can install by pasting into terminal:
curl -L https://releases.hashicorp.com/packer/0.10.0/packer_0.10.0_linux_amd64.zip -O
unzip packer_0.10.0_linux_amd64.zip
```

After unzipping the the downloaded file, move the binary to the root of the cloned git project above.

### Run build process

Open install.json file and populate the marked fields: name, source_image and networks.
```
   "builders":[
      {
         "type":"openstack",
         "identity_endpoint":"http://192.168.123.100:5000/v2.0",
         "tenant_name":"admin",
         "username":"admin",
         "password":"secretsecret",
         "region":"RegionOne",
         "ssh_username":"centos",
         "image_name":"<some name for the image>",
         "source_image":"<paste source image id ex. 7cc1b3-c3d8-4...etc>",
         "flavor":"m1.small",
         "networks":[
            "<paste PRIVATE network id ex. 9dcff775-7345-4a...etc>"
         ],
         "insecure":"true",
         "use_floating_ip":true,
         "ssh_pty":true
      }
   ],
   "provisioners":[
      {
         "type":"shell",
         "script":"install-docker.sh"
      },
      {
         "type":"shell",
         "script":"install-docker-bootstrap.sh"
      },
      {
         "type":"shell",
         "inline":[
            "sudo yum -y install bridge-utils",
            "sudo yum clean all",
            "sudo dd if=/dev/zero of=/EMPTY bs=1M | true",
            "sudo rm -f /EMPTY"
         ]
      }
   ]
}
```

- Building on DevStack requires all the following environment
variables. To do that just execute the openrc-default.sh. 
Make sure you enter the correct OS_TENANT_ID from Horizon: Identity -> Projects -> admin -> Project ID 

```
#!/bin/bash

export OS_IDENTITY_API_VERSION=2.0
export OS_USERNAME=admin
export OS_PASSWORD=secretsecret
export OS_AUTH_URL=http://192.168.123.100:5000/v2.0
export OS_TENANT_NAME=admin
export OS_TENANT_ID=0f3f383e84d24d618d3c8f9b2ccc8e20

```

### Source the openrc-default.sh

```
. openrc-default.sh
```

### Validate json file for correctnes:
```
./packer validate install.json
```

### Run build process:
```
./packer build install.json
```
### If everything is configured correctly you shuld see following output:
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

∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨∧∨

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

- Image should now be uploaded to OpenStack. You should see it on the HorizonUI under Project -> Images under the name assigned in the json file above.


