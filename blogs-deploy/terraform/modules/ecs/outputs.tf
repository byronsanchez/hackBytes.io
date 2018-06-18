output "repository_url_wintersmith_docker" {
  value = "${aws_ecr_repository.blogs-wintersmith-docker.repository_url}"
}

output "repository_url_blogs_hackbytes" {
  value = "${aws_ecr_repository.blogs_hackbytes.repository_url}"
}

output "repository_url_blogs_nitelite" {
  value = "${aws_ecr_repository.blogs_nitelite.repository_url}"
}
