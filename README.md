# Terraform AWS Infrastructure

![Terraform](https://img.icons8.com/color/144/000000/terraform.png)      ![AWS](https://img.icons8.com/color/144/000000/amazon-web-services.png)

This project uses Terraform to create and manage AWS infrastructure. The infrastructure is divided into two sub-projects: Day 1 and Day 2, each focusing on different aspects of the AWS setup.

## Project Overview

- **Day 1**: Basic VPC setup with subnets, internet gateway, NAT gateway, security groups, and EC2 instances.
- **Day 2**: Advanced setup including additional subnets, NAT gateways, route tables, security groups, application load balancer, auto-scaling group, and more.

## Sub-Projects

### Day 1

![Daigram](https://github.com/ibrahim-reda-2001/photo/blob/master/WhatsApp%20Image%202025-02-02%20at%2011.45.57_50fea60a.jpg)

Basic AWS infrastructure setup including:
- VPC
- Subnets
- Internet Gateway
- NAT Gateway
- Security Groups
- EC2 Instances
### Day 2

![Daigram](https://github.com/Amr-Awad/AutoScallerTerraform/blob/main/architecture.jfif)

Advanced AWS infrastructure setup including:
- Additional Subnets
- NAT Gateways
- Route Tables
- Security Groups
- Application Load Balancer
- Auto-Scaling Group
### Day  3
![Daigram](https://github.com/ibrahim-reda-2001/photo/blob/master/Lab3%5B1%5D.pdf%20and%202%20more%20pages%20-%20Profile%201%20-%20Microsoft%E2%80%8B%20Edge%202_6_2025%204_32_05%20PM.png)

Reverse proxy using AWS
- VPC
- AZ
- private subnets
- public subnets
- NAT Gatway
- Internet Gatway
- Internal Loadbalancer
- Public LoadBalancer 

## Usage

To apply the Terraform configuration and create the infrastructure, navigate to the respective sub-project directory and run the following commands:

```sh
terraform init
terraform apply
