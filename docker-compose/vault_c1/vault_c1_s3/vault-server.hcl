storage "raft" {
  path = "/vault/data"
  node_id = "vault_s3"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_cert_file = "/vault/config/vault_c1_chain.crt"
  tls_key_file = "/vault/config/vault_c1.key"
  telemetry {
    unauthenticated_metrics_access = true
  }
}

api_addr = "https://vault_c1_s3:8200"
cluster_addr = "https://vault_c1_s3:8201"

ui = "true"

license_path = "/vault/config/vault.hclic"

telemetry {
  prometheus_retention_time = "30s"
  disable_hostname = true
}