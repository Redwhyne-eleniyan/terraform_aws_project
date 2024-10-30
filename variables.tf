variable "cidr" {
  description = "cidr block value for vpc"
}

variable "cidr_block1" {
  description = "cidr block for subnet1"
}

variable "cidr_block2" {
  description = "cidr block for subnet2"
}

variable "ami" {
    description = "ami for aws_instance"
}

variable "instance_type" {
  description = "value for instance type"
}