locals {
  ami_id = data.aws_ami.k8s.id
  sg_id = data.aws_security_group.sg_id.id
  public_subnet_id = data.aws_subnet.default_pub_subnet_1a.id 
}


