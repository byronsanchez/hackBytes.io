# Configure the AWS Provider
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

module "iam" {
  source = "../modules/iam"

  iam_user = "byronsanchez-blogs"
}

module "hackbytes_io" {
  source = "../modules/web"
  
  iam_user = "${module.iam.iam_user}"
  domain = "hackbytes.io"
}

module "nitelite_io" {
  source = "../modules/web"

  iam_user = "${module.iam.iam_user}"
  domain = "nitelite.io"
}
