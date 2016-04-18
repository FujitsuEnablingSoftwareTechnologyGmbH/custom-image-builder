k8-nodeOS-builder
==================

Prerequisites
-------------
- Install [Packer.io](https://packer.io/downloads.html), see [installation instructions](https://packer.io/docs/installation.html).


Local Example using DevStack
--------------
Clone the following project [FujitsuEnablingSoftwareTechnologyGmbH/devstack-vagrant](https://github.com/FujitsuEnablingSoftwareTechnologyGmbH/devstack-vagrant) onto your local disk.

After cloning the repository, follow the steps on how to spin up an instance of DevStack in Vagrand.

#### Upload reference image via glance
```
$ cd devstack-vagrant
$ vagrant ssh

$ sudo su - stack
$ . devstack/openrc admin admin

$ curl -L http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1603.qcow2.xz -O
$ unxz CentOS-7-x86_64-GenericCloud-1603.qcow2.xz
$ glance image-create --name centos7 --disk-format qcow2 --container-format bare --file CentOS-7-x86_64-GenericCloud-1603.qcow2 --is-public True

$ exit
```

#### Configuring enviroment variables 
Building on DevStack requires all the following environment
variables. To do that just execute the env-vars-vm.sh 
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

#### Source the env-vars-vm.sh
After adding the enviroment variables to the env-vars-vm.sh file we need to source the file:
```
$ . env-vars-vm.sh 
	or 
$ source env-vars-vm.sh
```

#### Edit install_nodeos.json with correct parameters 
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
	 "image_name": "packer-demo-{{timestamp}}",
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
   "provisioners":[ ...
```

#### Validate json file for correctness:
```
$ ./packer validate install_nodeos.json
```

#### Run build process:
```
$ ./packer build install_nodeos.json
```

#### If everything is configured correctly you should see following output:
```
Openstack output will be in this color.

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


Cloud Example using Openstack on CityCloud
--------------
We are assuming that CityCloud or which ever public cloud provider you choose lets you create a reference image. Openstack api requires you to have a reference image on which the further provisioning will be based. After you have successfully created a reference image on your cloud, in this case a CentOS image, we will be using packer to further customize the image with necessary packages.

#### Configuring enviroment variables 
Building on OpenStack on City Cloud requires all the following environment variables (with example values) You will have to look these up from your cloud provider and populate them accordingly. It could also be that each cloud provider has their own set of required variables and that could be different from the ones below. 

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
#### Source the env-vars-cloud.sh
After adding the enviroment variables to the env-vars-cloud.sh file we need to source the file:
```
$ . env-vars-cloud.sh 
	or 
$ source env-vars-cloud.sh
```
#### Edit install_cloud.json with correct parameters 
Parameters with need to be inserted:
"image_name" - can leave as is or provide your own
"source_image" - usually available from cloud providers GUI
"flavor": - usually available from cloud providers GUI
"floating_ip": usually available from cloud providers GUI

Open install_cloud.json file and populate the fields from above:
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
  "provisioners": [ ...
```

#### Validate json file for correctness:
```
$ ./packer validate install_cloud.json
```

#### Run build process:
```
$ ./packer build install_cloud.json
```

#### If everything is configured correctly the output should be similar to the output produced when provisioning locally...
