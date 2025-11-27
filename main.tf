resource "aws_instance" "k8s_workstation" {
  ami = local.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [local.sg_id]
  subnet_id = local.public_subnet_id
  iam_instance_profile = aws_iam_instance_profile.k8s_workstation.name

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
    tags = {
      Name = "k8s-workstation"
    }
  }

  user_data = file("k8s-workstation.sh")

  tags = {
      Name = "k8s-workstation"
    }
}

resource "aws_iam_role" "k8s_workstation_role" {
  name = "K8SWorkstationRole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
        }
    ]
})

  tags = {
    Name = "K8SWorkstationRole"
  }
}

resource "aws_iam_instance_profile" "k8s_workstation" {
  name = "k8s_workstation"
  role = aws_iam_role.k8s_workstation_role.name
}

resource "aws_iam_policy" "k8s_workstation_policy" {
  name        = "K8SWorkstationPolicy"
  description = "K8s workstation policy allowing EKS/ECR/EC2/SSM."

  policy = file("k8s_workstation_policy.json")
}

resource "aws_iam_role_policy_attachment" "k8s_workstation_attach" {
  role       = aws_iam_role.k8s_workstation_role.name
  policy_arn = aws_iam_policy.k8s_workstation_policy.arn
}



# Attach managed policies
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.k8s_workstation_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.k8s_workstation_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_full_access" {
  role       = aws_iam_role.k8s_workstation_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "vpc_full_access" {
  role       = aws_iam_role.k8s_workstation_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_role_policy_attachment" "iam_full_access" {
  role       = aws_iam_role.k8s_workstation_role.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_role_policy_attachment" "cloudformation_full_access" {
  role       = aws_iam_role.k8s_workstation_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecr_full_access" {
  role       = aws_iam_role.k8s_workstation_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}


# Optional policies
resource "aws_iam_role_policy_attachment" "cloudtrail_full_access" {
  role       = aws_iam_role.k8s_workstation_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudTrail_FullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm_read_only" {
  role       = aws_iam_role.k8s_workstation_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}
