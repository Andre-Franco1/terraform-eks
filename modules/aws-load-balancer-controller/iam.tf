resource "aws_iam_role" "eks_controller_role" {
  name = "${var.project_name}-aws-load-balancer-controller-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${data.aws_region.current.region}.amazonaws.com/id/${local.oidc}"
                },
                "Action": "sts:AssumeRoleWithWebIdentity",
                "Condition": {
                    "StringEquals": {
                        "oidc.eks.${data.aws_region.current.region}.amazonaws.com/id/${local.oidc}:sub": "system:serviceaccount:default:my-service-account",
                        "oidc.eks.${data.aws_region.current.region}.amazonaws.com/id/${local.oidc}:aud": "sts.amazonaws.com"
                    }
                }
            }
        ]
}
EOF

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-aws-load-balancer-controller-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_controller_role_attachment" {
  role       = aws_iam_role.eks_controller_role.name
  policy_arn = aws_iam_policy.eks_controller_policy.arn
}