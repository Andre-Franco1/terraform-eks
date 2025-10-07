data "tls_certificate" "gh_actions_oidc_tls_certificate" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "gh_actions_oidc" {
  url = data.tls_certificate.gh_actions_oidc_tls_certificate.url

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = data.tls_certificate.gh_actions_oidc_tls_certificate.certificates[*].sha1_fingerprint

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-gh-actions-oidc"
    }
  )
}

resource "aws_iam_role" "gh_actions_oidc_role" {
  name = "${var.project_name}-gh-actions-oidc-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Federated": "${aws_iam_openid_connect_provider.gh_actions_oidc.arn}"
                },
                "Action": "sts:AssumeRoleWithWebIdentity"
                "Condition": {
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:Andre-Franco1/restapi-flask:*"
                },
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                }
            }
            }
        ]
}
EOF

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-gh-actions-oidc-role"
    }
  )
}
