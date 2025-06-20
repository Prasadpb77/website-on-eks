# EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids         = ["subnet-0aa88c728d36e67e5", "subnet-067b756a1fe79b1c4"]
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }
}

# aws-auth ConfigMap via Kubernetes provider
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = aws_iam_role.eks_node.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      },
      {
        rolearn  = aws_iam_role.bastion_role.arn
        username = "bastion-user"
        groups   = ["system:masters"]
      }
    ])
  }
  depends_on = [aws_eks_cluster.eks]
}

resource "kubernetes_service_account" "alb_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_ingress_controller_role.arn
    }
  }
}

# EKS Node Group
resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "eks-nodes"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = ["subnet-0aa88c728d36e67e5", "subnet-067b756a1fe79b1c4"]
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  instance_types = ["t3.medium"]
}