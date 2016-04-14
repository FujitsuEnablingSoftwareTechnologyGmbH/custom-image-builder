### FAQ
#### **How to upload reference image to devstack-vagrant?**

In our case we will be using the [CentOS-7-x86_64 GenericCloud](http://cloud.centos.org/centos/7/images/) image.
```
## cd into the directory where the project was cloned
$ cd devstack-vagrant
$ vagrant ssh

$ sudo su - stack
$ . devstack/openrc admin admin

$ curl -L http://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1603.qcow2.xz -O
$ unxz CentOS-7-x86_64-GenericCloud-1603.qcow2.xz
$ glance image-create --name centos7 --disk-format qcow2 --container-format bare --file CentOS-7-x86_64-GenericCloud-1603.qcow2 --is-public True

$ exit
```

#### **How to configure environment variables?**

Building to DevStack requires all if the following environment variables to be set accordingly. Every variable should be left unedited with the exceptions of **OS_TENANT_ID**. To get this value go to Horizon: **Identity -> Projects -> admin -> Project ID**
```
#!/bin/bash

export OS_IDENTITY_API_VERSION=2.0
export OS_USERNAME=admin
export OS_PASSWORD=secretsecret
export OS_AUTH_URL=http://192.168.123.100:5000/v2.0
export OS_TENANT_NAME=admin
export OS_TENANT_ID=0f3f383e84d24d618d3c8f9b2ccc8e20
```
After adding the environment variables to the env-vars.sh file we need to source the file:
```
$ . env-vars.sh
	or
$ source env-vars.sh
```

#### **How to spin up and instance of Openstack in Vagrant?**

Follow instructions outlined in [FujitsuEnablingSoftwareTechnologyGmbH/devstack-vagrant](https://github.com/FujitsuEnablingSoftwareTechnologyGmbH/devstack-vagrant) project.
