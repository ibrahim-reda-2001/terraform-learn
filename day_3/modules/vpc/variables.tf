variable "vpc_cidr" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "public_subnets" {
  type = list(object({
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  type = list(object({
    cidr = string
    az   = string
  }))
}