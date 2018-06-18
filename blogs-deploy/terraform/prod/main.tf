# Configure the AWS Provider
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

module "iam" {
  source = "../modules/iam"

  iam_user = "byronsanchez-blogs"
}

module "ecs" {
  source = "../modules/ecs"

  repository_name_wintersmith_docker = "byronsanchez/wintersmith-docker"
  repository_name_blogs_hackbytes = "byronsanchez/blogs-hackbytes"
  repository_name_blogs_nitelite = "byronsanchez/blogs-nitelite"
}

# I could have one code pipeline for all websites, or 1 per website.
# Right now, I'm going for just a single one for all. This is because if I had
# one per website, they'd all still get triggered by the same source, and they'd
# all run their own builds regardless.
#
# Which should make sense since they all share source files, and a global
# template change /should/ invalidate all websites.
#
# So I'd rather just save on resources and have a single build pipeline cook up
# all the websites in one go. The tradeoff is the variable mess you see here,
# which is what gave me the idea of one per site, but nah, not worth it atm.
module "code_pipeline" {
  source = "../modules/code_pipeline"

  project_name = "blogs"
  github_token = "${var.github_token}"
  region = "${var.aws_region}"

  repository_url_wintersmith_docker = "${module.ecs.repository_url_wintersmith_docker}"
  repository_url_blogs_hackbytes = "${module.ecs.repository_url_blogs_hackbytes}"
  repository_url_blogs_nitelite = "${module.ecs.repository_url_blogs_nitelite}"
  
  s3_bucket_name_blogs_hackbytes = "${module.blogs_hackbytes.bucket_name}"
  s3_bucket_name_blogs_nitelite = "${module.blogs_nitelite.bucket_name}"
}

module "blogs_hackbytes" {
  source = "../modules/web"

  iam_user = "${module.iam.iam_user}"
  domain = "hackbytes.io"
}

module "blogs_nitelite" {
  source = "../modules/web"

  iam_user = "${module.iam.iam_user}"
  domain = "nitelite.io"
}

module "demo_hackbytes_com" {
  source = "../modules/web"

  iam_user = "${module.iam.iam_user}"
  domain = "demo.hackbytes.com"
}
