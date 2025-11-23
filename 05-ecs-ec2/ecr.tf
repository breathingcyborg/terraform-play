# registry for private docker image
resource "aws_ecr_repository" "repo" {
  name                 = "tf_play_hello_world"
  image_tag_mutability = "MUTABLE"
}