# Bastion Host with role
resource "aws_instance" "bastion" {
  ami                    = "ami-0cbad6815f3a09a6d"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-0aa88c728d36e67e5"
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.bastion_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              curl -LO "https://dl.k8s.io/release/v1.32.0/bin/linux/amd64/kubectl"
              chmod +x kubectl
              mv kubectl /usr/local/bin/
              kubectl version --client
              curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
              mv /tmp/eksctl /usr/local/bin
              curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              yum install -y git
              EOF

  tags = {
    Name = "eks-bastion"
  }
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion-instance-profile"
  role = aws_iam_role.bastion_role.name
}