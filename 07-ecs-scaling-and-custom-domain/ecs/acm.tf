data "terraform_remote_state" "ssl_state" {
  backend = "local"
  config = {
    path = "../ssl/terraform.tfstate"
  }
}