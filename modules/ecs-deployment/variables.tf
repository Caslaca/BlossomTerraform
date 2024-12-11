variable "ecs_deployment_image" {
    description = "The Docker image to deploy to the ECS cluster"
    type = string
}

variable "ecs_deployment_name" {
    description = "The name of the ECS deployment"
    type = string
}

variable "internal_alb" {
    description = "Whether to use an internal ALB"
    type = bool
    default = false
}

# variable "vpc_name" {
#     description = "The name of the VPC"
#     type = string
  
# }

variable "app_port" {
  description = "The port on which the application listens"
  type        = number
}

variable "aws_ecs_cluster_id" {
    description = "The ID of the ECS cluster"
    type = string
  
}
variable "vpc_id" {
    description = "The ID of the VPC"
    type = string
}

variable "private_subnet_ids" {
    description = "The IDs of the private subnets"
    type = list(string)
}

variable "public_subnet_ids" {
    description = "The IDs of the public subnets"
    type = list(string)
}

variable "execution_role_arn" {
    description = "The ARN of the ECS task execution role"
    type = string
  
}
variable "environment_vars" {
    description = "A list of environment variables to set in the container"
    type = list(object({
        name  = string
        value = string
    }))
    default = []
}

variable "ecs_container_name" {
    description = "The name of the ECS container"
    type = string
}

variable "namespace_arn" {
    description = "The ARN of the service discovery namespace"
    type = string
}

variable "sg_ids" {
    description = "The IDs of the security groups"
    type = list(string)
}

variable "health_check_code" {
    description = "The health check code"
    type = string
    default = "200"
  
}

variable "replicas" {
    description = "The number of replicas to run"
    type = number
    default = 1
}