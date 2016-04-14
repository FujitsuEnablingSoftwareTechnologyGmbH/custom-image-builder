# k8s-nodeOS-builder
> building custom image files for [docker based provisioning](https://github.com/FujitsuEnablingSoftwareTechnologyGmbH/k8s-docker-provisioner)

### Introduction

This project describes the process on how to create a base image that can be used for the [Docker Based Provisioning](https://github.com/FujitsuEnablingSoftwareTechnologyGmbH/k8s-docker-provisioner) project. Unlike other script based provisioning approaches, docker based provisioning will provision a kubernetes cluster by creating and launching only docker containers.

### Prerequisities

The prerequisites for the docker based provisioning are:
* [Docker](https://www.docker.com/)
* Configuration of Docker called **Docker Bootstrap**.
  * This particular configuration uses two docker daemons that are run in place of a typical, single daemon setup. The additional docker bootstrap daemon run etcd and flannel as docker containers, which in turn provide the network interface for the main docker daemon.

### Supported formats

Currently supported OS:
- [CentOS](https://www.centos.org/)

Currently supported image type:
*can easily be extended to other operating systems and image types*
- [QCOW (OpenStack)](https://github.com/kenan435/k8s-nodeos-builder/blob/k8s-nodeos-builder/Openstack/README.md)


#### Kubernetes cluster with main and bootstrap docker daemons
![Alt text](https://raw.githubusercontent.com/kenan435/k8s-nodeos-builder/k8s-nodeos-builder/k8s-docker.png "k8s Docker Based Provisioning")
