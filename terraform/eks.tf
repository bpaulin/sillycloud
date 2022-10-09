resource "aws_eks_cluster" "sillykloud" {
  name = "sillykloud"

  # Iam
  role_arn = aws_iam_role.eks-sillykloud.arn
  depends_on = [
    aws_iam_role_policy_attachment.eks-sillykloud-AmazonEKSClusterPolicy,
  ]

  vpc_config {
    subnet_ids = [aws_subnet.main.id]
  }
}

