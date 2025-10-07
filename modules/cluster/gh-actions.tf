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