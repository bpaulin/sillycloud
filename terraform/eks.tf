resource "aws_eks_cluster" "sillykloud" {
  name = "sillykloud"

  # Iam
  role_arn = aws_iam_role.eks-sillykloud.arn
  depends_on = [
    aws_iam_role_policy_attachment.eks-sillykloud-AmazonEKSClusterPolicy,
  ]

  vpc_config {
    subnet_ids = [
      aws_subnet.sillykloud-public1.id
    ]
    # No bastion for now
    #tfsec:ignore:aws-eks-no-public-cluster-access
    endpoint_public_access = true
    public_access_cidrs    = [data.sops_file.secrets.data["ip_home"]]
  }
  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.kube-secrets.arn
    }
  }

  enabled_cluster_log_types = ["api", "authenticator", "audit", "scheduler", "controllerManager"]
}

