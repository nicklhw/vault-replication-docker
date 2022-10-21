resource "vault_mount" "kvv2" {
  path        = "secret"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "time_sleep" "wait" {
  depends_on      = [vault_mount.kvv2]
  create_duration = "10s"
}

resource "null_resource" "kv1_to_kv2_migration" {
  depends_on = [time_sleep.wait]
}

resource "vault_kv_secret_v2" "secret" {
  depends_on = [null_resource.kv1_to_kv2_migration]
  mount      = vault_mount.kvv2.path
  name       = "foo"
  data_json = jsonencode(
    {
      foo   = "bar",
      pizza = "cheese"
    }
  )
}