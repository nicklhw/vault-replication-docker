storage "raft" {
  path = "/vault/data"
  node_id = "vault_s2"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_cert_file = "/vault/config/vault_c3.crt"
  tls_key_file = "/vault/config/vault_c3.key"
  tls_ca_cert_file = "/vault/config/vault_ca.crt"
}

api_addr = "https://vault_c3_s2:8200"
cluster_addr = "https://vault_c3_s2:8201"

ui = "true"

license_path = "/vault/config/vault.hclic"