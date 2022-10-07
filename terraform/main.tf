terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.9.1"
    }
  }
}

provider "vault" {
  address         = "https://localhost:9200"
  skip_tls_verify = "true"
}


