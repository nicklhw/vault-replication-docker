
resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "demo" {
  backend        = vault_auth_backend.approle.path
  role_name      = "demo-role"
  token_ttl      = 60
  token_max_ttl  = 300
  token_policies = ["default", "admin"]
}

resource "vault_approle_auth_backend_role_secret_id" "id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.demo.role_name
}

data "vault_approle_auth_backend_role_id" "demo" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.demo.role_name
}

resource "local_file" "approle_id" {
  content  = data.vault_approle_auth_backend_role_id.demo.role_id
  filename = "../docker-compose/vault-agent/role_id"
}

resource "local_file" "approle_secret" {
  content  = vault_approle_auth_backend_role_secret_id.id.secret_id
  filename = "../docker-compose/vault-agent/secret_id"
}