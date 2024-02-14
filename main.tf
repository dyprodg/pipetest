resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "mein-codepipeline-artefakt-bucket"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_codebuild_project" "build_and_test" {
  name          = "BuildTest"
  description   = "Baut und testet die Flask Anwendung"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:4.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "PROJECT_NAME"
      value = "Pipeline Python Flask"
    }
  }

  source {
    type = "CODEPIPELINE"

  }
}

resource "aws_codepipeline" "meine_pipeline" {
  name     = "FlaskPipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  pipeline_type = "V2"

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn = var.codestar_connection_arn
        FullRepositoryId = "dyprodg/pipetest"
        BranchName = "main"
        DetectChanges = "true"
      }
    }
  }

  stage {
    name = "BuildAndTest"
    action {
      name             = "BuildAndTest"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = "BuildTest"
      }
    }
  }

  stage {
    name = "Approval"
    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }
}

# Umfassende IAM Policy für CodeBuild und CodePipeline
resource "aws_iam_policy" "codepipeline_codebuild_full_access" {
  name        = "codepipeline_codebuild_full_access"
  description = "Gewährt volle Zugriffsrechte auf CodeBuild und CodePipeline"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codebuild:*",
          "codepipeline:*",
          "codestar-connections:UseConnection",
          "logs:*",
        ],
        Resource = "*"
      },
            {
        Effect = "Allow",
        Action = "s3:*",
        Resource = [
          "${aws_s3_bucket.codepipeline_bucket.arn}",
          "${aws_s3_bucket.codepipeline_bucket.arn}/*"
        ]
      },
    ]
  })
}

# Anhängen der umfassenden Policy an beide Rollen
resource "aws_iam_role_policy_attachment" "codepipeline_full_access_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_codebuild_full_access.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_full_access_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codepipeline_codebuild_full_access.arn
}
