resource "aws_ecr_repository" "repo" {
  name = "tf_play_07"

  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

  image_tag_mutability_exclusion_filter {
    filter = "latest"
    filter_type = "WILDCARD"
  }
}