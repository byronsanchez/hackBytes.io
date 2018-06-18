
/*====
ECR repositories for our images
======*/

resource "aws_ecr_repository" "blogs-wintersmith-docker" {
  name = "${var.repository_name_wintersmith_docker}"
}

resource "aws_ecr_repository" "blogs_hackbytes" {
  name = "${var.repository_name_blogs_hackbytes}"
}

resource "aws_ecr_repository" "blogs_nitelite" {
  name = "${var.repository_name_blogs_nitelite}"
}

