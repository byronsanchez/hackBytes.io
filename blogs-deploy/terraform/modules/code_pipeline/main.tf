resource "aws_s3_bucket" "source" {
  bucket        = "${var.project_name}-source"
  acl           = "private"
  force_destroy = true
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.project_name}-codepipeline-role"

  assume_role_policy = "${file("${path.module}/policies/codepipeline_role.json")}"
}

/* policies */
data "template_file" "codepipeline_policy" {
  template = "${file("${path.module}/policies/codepipeline.json")}"

  vars {
	aws_s3_bucket_arn = "${aws_s3_bucket.source.arn}"
	domain_blogs_hackbytes = "${var.s3_bucket_name_blogs_hackbytes}"
	domain_blogs_nitelite = "${var.s3_bucket_name_blogs_nitelite}"
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = "${aws_iam_role.codepipeline_role.id}"
  policy = "${data.template_file.codepipeline_policy.rendered}"
}

/*
/* CodeBuild
*/
resource "aws_iam_role" "codebuild_role" {
  name               = "${var.project_name}-codebuild-role"
  assume_role_policy = "${file("${path.module}/policies/codebuild_role.json")}"
}

data "template_file" "codebuild_policy" {
  template = "${file("${path.module}/policies/codebuild_policy.json")}"

  vars {
    aws_s3_bucket_arn = "${aws_s3_bucket.source.arn}"
	domain_blogs_hackbytes = "${var.s3_bucket_name_blogs_hackbytes}"
	domain_blogs_nitelite = "${var.s3_bucket_name_blogs_nitelite}"
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name        = "codebuild-policy"
  role        = "${aws_iam_role.codebuild_role.id}"
  policy      = "${data.template_file.codebuild_policy.rendered}"
}

data "template_file" "buildspec" {
  template = "${file("${path.module}/buildspec.yml")}"

  vars {
	repository_url_wintersmith_docker = "${var.repository_url_wintersmith_docker}"
	repository_url_blogs_hackbytes = "${var.repository_url_blogs_hackbytes}"
	repository_url_blogs_nitelite = "${var.repository_url_blogs_nitelite}"
	region = "${var.region}"
	s3_bucket_name_blogs_hackbytes = "${var.s3_bucket_name_blogs_hackbytes}"
	s3_bucket_name_blogs_nitelite = "${var.s3_bucket_name_blogs_nitelite}"
  }
}


resource "aws_codebuild_project" "project_build" {
  name          = "${var.project_name}-codebuild"
  build_timeout = "20"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    // https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
    //image           = "aws/codebuild/docker:17.09.0"
    image           = "aws/codebuild/nodejs:10.1.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${data.template_file.buildspec.rendered}"
  }
}

/* CodePipeline */

resource "aws_codepipeline" "pipeline" {
  name     = "${var.project_name}-pipeline"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.source.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration {
        OAuthToken = "${var.github_token}"
        Owner      = "byronsanchez"
        Repo       = "${var.project_name}"
        Branch     = "master"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["blogs"]

      configuration {
        ProjectName = "${var.project_name}-codebuild"
      }
    }
  }

}
