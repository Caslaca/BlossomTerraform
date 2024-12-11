variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "172.17.0.0/16"

}

variable "count_az" {
  description = "The number of availability zones to use"
  type        = number
  default     = 2
}

# variable "app_port" {
#   description = "The port on which the application listens"
#   type        = number
# }

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}