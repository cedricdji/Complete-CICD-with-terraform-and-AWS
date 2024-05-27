terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 4.0"
      }
    }
    backend "s3" {
      bucket = "terraform-state-2021"
      key    = "aws/ec2-deploy/terraform.tfstate"
      region = "eu-west-3"
      
    }
}

provider "aws" {
  region = var.region
}
resource "aws_instance" "server" {
  ami = "ami-00ac45f3035ff009e"
  instance_type = "t2.micro"
  key_name = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.maingroup.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    private_key = var.private_key
    timeout = "4m"
    }
    tags = {
      Name = "DeployVM"
    }
}
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = "EC2--ECR-AUTH"
  
}

resource "aws_security_group" "maingroup" {
    egress {
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all traffic out"
        from_port = 0
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        protocol = "-1"
        security_groups = []
        self = false
        to_port = 0
    }
    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow SSH traffic in"
        from_port = 22
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        protocol = "tcp"
        security_groups = []
        self = false
        to_port = 22
    }
    ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic in"
    from_port = 80
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "tcp"
    security_groups = []
    self = false
    to_port = 80
    }

}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = var.public_key
}

output "instance_public_ip" {
  value = aws_instance.server.public_ip
  sensitive = false
}