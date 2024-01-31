data "aws_availability_zones" "available" {
  state        = "available"
}

data "aws_ami" "linux" {
   most_recent = true
   owners      = ["amazon"]

  filter {
    name       = "name"
    values     = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name       = "virtualization-type"
    values     = ["hvm"]
  }
}

locals {
  db_address     = aws_db_instance.turing_db.address
  db_username    = "${var.db_admin_username}"
  db_password    = "${var.db_admin_password}"
}

# Worker node key pair

resource "tls_private_key" "rsa" {
  algorithm    = "RSA"
  rsa_bits     = 4096
}

resource "local_file" "workernode_key" {
  content      = tls_private_key.rsa.private_key_pem
  filename     = "${var.project}-key-pair.pem"

  depends_on   = [
    tls_private_key.rsa
    ]
}

resource "aws_key_pair" "EKS_workernode_key_pair" {
  key_name     = "${var.project}-key-pair"
  public_key   = tls_private_key.rsa.public_key_openssh

  depends_on   = [
    tls_private_key.rsa
    ]
}

data "tls_certificate" "eks_cluster" {
  url = aws_eks_cluster.inforiver_eks.identity[0].oidc[0].issuer
}


