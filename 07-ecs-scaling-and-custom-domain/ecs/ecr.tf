# Outputs of "container_registry" stack
data "terraform_remote_state" "container_registry_stack" {
  backend = "local"
  config = {
    path = "../container-registry/terraform.tfstate"
  }
}
