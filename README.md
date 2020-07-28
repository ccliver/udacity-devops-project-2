# Project 2 for the [Udacity DevOps Engineer Nanodegree](https://www.udacity.com/course/cloud-dev-ops-nanodegree--nd9991)

## Deploy a High-Availability Web App Using CloudFormation

### Problem
Your company is creating an Instagram clone called Udagram. Developers pushed the latest version of their code in a zip file located in an S3 Bucket. You have been tasked with deploying the application, along with the necessary supporting software into its matching infrastructure. This needs to be done in an automated fashion so that the infrastructure can be discarded as soon as the testing team finishes their tests and gathers their results.


### Requirements
  - 4 servers across 2 AZ's in autoscaling groups
  - 2 vCPUs per server 4G of RAM, and 10G disks running Ubuntu 18
  - One step build/destroy process
  - Secure secret storage


---


### Architecture Diagram
![Architecture Diagram](images/architecture-diagram.jpg)

### Build the environment
```bash
make generate_bastion_key build_stack
```