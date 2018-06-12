# Defines a user that should be able to write to your bucket
resource "aws_iam_user" "prod_user" {
  name = "${var.iam_user}"
}

resource "aws_iam_access_key" "prod_user" {
  user = "${aws_iam_user.prod_user.name}"
}
