provider "google" {
  project = var.project
}

data "google_client_config" "current" {}