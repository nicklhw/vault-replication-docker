storage "raft" {
  path = "/vault/data"
  node_id = "vault_s2"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_cert_file = "/vault/config/vault_c1_chain.crt"
  tls_key_file = "/vault/config/vault_c1.key"
}

api_addr = "https://vault_c1_s2:8200"
cluster_addr = "https://vault_c1_s2:8201"

ui = "true"
