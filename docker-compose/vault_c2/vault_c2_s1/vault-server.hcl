storage "raft" {
  path = "/vault/data"
  node_id = "vault_s1"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_cert_file = "/vault/config/vault_c2_chain.crt"
  tls_key_file = "/vault/config/vault_c2.key"
}

api_addr = "https://vault_c2_s1:8200"
cluster_addr = "https://vault_c2_s1:8201"

ui = "true"

license_path = "/vault/config/vault.hclic"