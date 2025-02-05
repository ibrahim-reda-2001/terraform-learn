variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_sg_id" {
  type = string
}

variable "public_instance_ids" {
  type = list(string)
}

variable "private_instance_ids" {
  type = list(string)
}