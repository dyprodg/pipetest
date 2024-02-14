resource "aws_codedeploy_app" "example" {
  name             = "httpd-codedeploy-app"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "example" {
  app_name              = aws_codedeploy_app.example.name
  deployment_group_name = "example-codedeploy-deployment-group"
  service_role_arn      = aws_iam_role.codedeploy_service_role.arn

  ec2_tag_filter {
    type  = "KEY_AND_VALUE"
    key   = "Name"
    value = "httpd-instance"
  }


  deployment_style {
    deployment_type = "IN_PLACE"
  }
}

resource "aws_iam_role" "codedeploy_service_role" {
  name               = "codedeploy-service-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "codedeploy_policy" {
  name        = "codedeploy-policy"
  description = "Policy for CodeDeploy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:Get*",
        "codedeploy:CreateDeployment",
        "codedeploy:RegisterApplicationRevision",
        "codedeploy:DeregisterOnPremisesInstance",
        "codedeploy:RegisterOnPremisesInstance"
      ],
      "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": "s3:*",
        "Resource": [
          "${aws_s3_bucket.codepipeline_bucket.arn}",
          "${aws_s3_bucket.codepipeline_bucket.arn}/*"
        ]
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "codedeploy_attachment" {
  role       = aws_iam_role.codedeploy_service_role.name
  policy_arn = aws_iam_policy.codedeploy_policy.arn
}
