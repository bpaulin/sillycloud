resource "aws_eks_node_group" "spot-nodes" {
  cluster_name    = aws_eks_cluster.sillykloud.name
  node_group_name = "spot-nodes"
  capacity_type   = "SPOT"
  instance_types  = ["t3a.small"]
  ami_type        = "AL2_x86_64"
  node_role_arn   = aws_iam_role.sillykloud-nodes.arn
  subnet_ids = [
    aws_subnet.sillykloud-private1.id,
    aws_subnet.sillykloud-private2.id
  ]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.sillykloud-nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.sillykloud-nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.sillykloud-nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "sillykloud-nodes" {
  name = "eks-node-group-sillykloud-nodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "sillykloud-nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.sillykloud-nodes.name
}

resource "aws_iam_role_policy_attachment" "sillykloud-nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.sillykloud-nodes.name
}

resource "aws_iam_role_policy_attachment" "sillykloud-nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.sillykloud-nodes.name
}
