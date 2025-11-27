data "aws_ami" "k8s" {
  most_recent      = true
  owners           = ["973714476881"]

  filter {
    name   = "name"
    values = ["RHEL-9-DevOps-Practice"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_subnet" "default_pub_subnet_1a" {
  availability_zone = "us-east-1a"
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  } 
}

data "aws_security_group" "sg_id" {
  name = "devsecgrp"
}