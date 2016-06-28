# k8s-nodeOS-builder
> building custom image files for [docker based provisioning](https://github.com/FujitsuEnablingSoftwareTechnologyGmbH/k8s-docker-provisioner)

### Introduction

This project describes the process on how to create a base image that can be used for the [Docker Based Provisioning](https://github.com/FujitsuEnablingSoftwareTechnologyGmbH/k8s-docker-provisioner) project. Unlike other script based provisioning approaches, docker based provisioning will provision a kubernetes cluster by creating and launching only docker containers.

### Prerequisities

* [Docker](https://www.docker.com/)

### Supported formats

Currently supported OS:
- [CentOS](https://www.centos.org/)

Currently supported image type:
*can easily be extended to other operating systems and image types*
- [QCOW (OpenStack)](https://github.com/kenan435/k8s-nodeos-builder/blob/k8s-nodeos-builder/Openstack/README.md)
