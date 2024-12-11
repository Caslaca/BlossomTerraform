# Terraform AWS ECS Cluster

This project sets up an AWS ECS Cluster with various resources including IAM roles, VPC, subnets, RDS instance, ECS services, and ALBs.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) v0.12.0 or higher
- AWS CLI configured with appropriate credentials
- An AWS account with necessary permissions
- Log group `/ecs/test-api` and `/ecs/test-app` should be created in the aws account
- The ECR repositories for test-api and test-app should be created
- The ECR images should be pushed to the repositories

## Dependencies

The project uses the following Terraform providers and modules:

- **Providers**:
  - `hashicorp/aws` version `~> 4.0`

- **Modules**:
  - `ecs-deployment` for ECS service and task definition
  - `network` for VPC and subnet setup

## Infrastructure

The Terraform configuration sets up the following infrastructure:

### IAM Policies and Roles

- **IAM Policy**: `AmazonECSTaskExecutionRolePolicy`
- **IAM Role**: `ecsTaskExecutionRole` with attached policies

### VPC and Networking

- **VPC**: Default VPC with CIDR block `172.31.0.0/16`
- **Security Groups**: Default VPC security groups
- **Subnets**: Public and private subnets within the default VPC

### RDS (Relational Database Service)

- **RDS Instance**: PostgreSQL database instance with endpoint `postgres.cxu4w2yuqrfd.us-west-1.rds.amazonaws.com`
- **Parameter Group**: Custom parameter group for PostgreSQL
- **Subnet Group**: Subnet group for the RDS instance

### ECS (Elastic Container Service)

- **ECS Cluster**: `dev-ecs-cluster`
- **Service Discovery Namespace**: `development`

### ECS Services and Task Definitions

- **ECS Service**: `test-api` and `test-app` applications
- **Task Definitions**: Definitions for `test-api` and `test-app` applications

### Load Balancers

- **Application Load Balancer (ALB)**: For `test-api` and `test-app` applications
- **Listeners**: HTTP listeners for the ALBs
- **Target Groups**: Target groups for the ALBs

## Usage
Before run any command you have to updated the `ecs_deployment_image` field in the `ecs_cluster/ecs_cluster.tf` file.

1. Clone the repository:
```sh
   git clone <repository-url>
   cd <repository-directory>
```
2. initialize Terraform
```
terraform init
```
3. Plan the infrastructure:
```
terraform plan
```
4. Aply the configuration:
```
terraform apply
```