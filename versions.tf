terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "1.13.3"
    }
  }
  required_version = ">= 0.13"
}
