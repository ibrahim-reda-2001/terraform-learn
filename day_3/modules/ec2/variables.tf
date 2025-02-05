variable "ami_id" {
  type = string
}

variable "instance_type" {
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

variable "key_name" {
  type = string
}

variable "public_user_data" {
  type = string
}

variable "private_user_data" {
  type = string
}