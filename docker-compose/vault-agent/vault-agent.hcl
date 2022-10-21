pid_file = "./pidfile"

auto_auth {
  method {
    type = "approle"

    config = {
      role_id_file_path = "/vault-agent/role_id"
      secret_id_file_path = "/vault-agent/secret_id"
      remove_secret_id_file_after_reading = false
    }
  }

  sink {
    type = "file"
    config = {
      path = "/vault-agent/token"
    }
  }
}

template_config {
  static_secret_render_interval = "1m"
}

template {
  source = "/vault-agent/kv.tpl"
  destination = "/usr/share/nginx/html/kv.html"
}

template {
  source = "/vault-agent/pki.tpl"
  destination = "/usr/share/nginx/html/pki.html"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = true
}

vault {
  address = "https://haproxy_glb"
}
