variable "project_name" {
  description = "Name of the project"
}

variable "github_token" {
  description = "Github token for pulling repositories"
}

variable "repository_url_wintersmith_docker" {
  description = "The url of the ECR repository for the API"
}

variable "repository_url_blogs_hackbytes" {
  description = "The url of the ECR repository for the web"
}

variable "repository_url_blogs_nitelite" {
  description = "The url of the ECR repository for the web"
}

variable "region" {
  description = "The region to use"
}

variable "s3_bucket_name_blogs_hackbytes" {
  description = "The bucket to which we will deploy static assets"
}

variable "s3_bucket_name_blogs_nitelite" {
  description = "The bucket to which we will deploy static assets"
}
