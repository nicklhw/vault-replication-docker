terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.4.1"
    }
  }
}

provider "vault" {
  address = "https://localhost:9201"
}

locals {
  default_3y_in_sec  = 94608000
  default_1y_in_sec  = 31536000
  default_1hr_in_sec = 3600
}

resource "vault_mount" "pki" {
  path                      = "pki"
  type                      = "pki"
  default_lease_ttl_seconds = local.default_3y_in_sec
  max_lease_ttl_seconds     = local.default_3y_in_sec
}

resource "vault_pki_secret_backend_root_cert" "root-ca" {
  depends_on           = [vault_mount.pki]
  backend              = vault_mount.pki.path
  type                 = "internal"
  common_name          = "example.com"
  ttl                  = local.default_1y_in_sec
  format               = "pem"
  private_key_format   = "der"
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true
  ou                   = "test"
  organization         = "test org"
}

resource "vault_pki_secret_backend_role" "root-ca-role" {
  backend          = vault_mount.pki.path
  name             = "servers"
  ttl              = local.default_1hr_in_sec
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["example.com"]
  allow_subdomains = true
}

resource "vault_pki_secret_backend_config_urls" "root-ca-config-urls" {
  backend = vault_mount.pki.path
  issuing_certificates = [
    "https://127.0.0.1:9201/v1/pki/ca",
  ]
}

resource "vault_mount" "pki_ica1" {
  path                      = "pki_int"
  type                      = "pki"
  default_lease_ttl_seconds = local.default_1hr_in_sec
  max_lease_ttl_seconds     = local.default_1hr_in_sec
}

resource "vault_pki_secret_backend_intermediate_cert_request" "ica1-cert-req" {
  depends_on   = [vault_mount.pki_ica1]
  backend      = vault_mount.pki_ica1.path
  type         = "internal"
  common_name  = "Intermediate CA1 v1"
  key_type     = "rsa"
  key_bits     = "2048"
  ou           = "test org"
  organization = "test"
  country      = "US"
  locality     = "Bethesda"
  province     = "MD"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "sign-ica1" {
  depends_on           = [vault_pki_secret_backend_intermediate_cert_request.ica1-cert-req]
  backend              = vault_mount.pki.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.ica1-cert-req.csr
  common_name          = "Intermediate CA1 v1"
  exclude_cn_from_sans = true
  ttl                  = local.default_1y_in_sec
  ou                   = "test"
  organization         = "test org"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "ica1-set-signed" {
  backend     = vault_mount.pki_ica1.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.sign-ica1.certificate
}

resource "vault_pki_secret_backend_role" "ica1-role" {
  backend          = vault_mount.pki_ica1.path
  name             = "example-dot-com"
  ttl              = local.default_1hr_in_sec
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["example.com"]
  allow_subdomains = true
}

resource "vault_pki_secret_backend_cert" "app" {
  depends_on = [vault_pki_secret_backend_role.ica1-role]
  backend = vault_mount.pki_ica1.path
  name = vault_pki_secret_backend_role.ica1-role.name
  common_name = "test.example.com"
}