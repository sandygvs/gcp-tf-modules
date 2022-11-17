terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.58.0, <5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 3.58.0, <5.0"
    }
  }
  required_version = ">= 0.14.0"
}