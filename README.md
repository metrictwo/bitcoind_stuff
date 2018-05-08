# Playing around with bitcoind

This repo contains the following:
* A Dockerfile for building bitcoind from source using a multi-stage build to keep the final image of reasonable size
* A terraform module for creating an EC2 instance with port 8333 open
* Simple Ansible playbooks for building a Docker bitcoind image and running it
* A Kubernetes deployment/service for bitcoind, using our Docker image

## Terraform
Assuming you have AWS credentials in your environment/file system, and an exising keypair in EC2, you can run the terraform module with:
```
cd terraform
terraform plan -var user=<your_name> -var key_name=<your_keypair>
terraform apply -var user=<your_name> -var key_name=<your_keypair>
```
When ready to destroy, do so with:
```
terraform destroy -var user=<your_name> -var key_name=<your_keypair>
```
For simplicity, this does not use an EBS volume for the data-dir of bitoind, but should in production.

## Ansible
There are two playbooks here, build.yml and run.yml. The build.yml playbook simply builds the docker image and pushes it to Docker Hub. The run.yml playbook will connect to a host, install Docker, and run the container. To run the build-playbook (it takes a while), I ran:
```
ansible-playbook build.yml
```
To run the container against an EC2 instances created from the terraform module above:
```
ansible-playbook run.yml -i ec2.py -b -u ec2-user
```
This uses the community script to pull dynamic inventory from EC2. It will match against the "Service" tag (= "bitcoind").

## Kubernetes
The kubernetes/ directory contains a Kubernetes Deployment and Service. It uses a basic hostPath volume mount for the data directory for demonstration purposes.
