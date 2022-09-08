#!/bin/bash

set -euo pipefail

# Enable DR Primary Replication
echo "Enable DR Primary Replication"
export VAULT_SKIP_VERIFY=true
export VAULT_INIT_OUTPUT=vault_c1.json
export VAULT_ADDR=https://localhost:9201
export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')

vault write -f sys/replication/dr/primary/enable primary_cluster_addr="https://haproxy_int:18201"

sleep 5

vault write sys/replication/dr/primary/secondary-token -format=json id="dr_secondary" > dr_activation.json

sleep 5

# Enable DR Secondary Replication
echo "Enable DR Secondary Replication"
export VAULT_INIT_OUTPUT=vault_c2.json
export VAULT_ADDR=https://localhost:9202
export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')

vault write \
  sys/replication/dr/secondary/enable \
  primary_api_addr="https://haproxy_int:18200" \
  token=$(cat dr_activation.json | jq -r '.wrap_info.token') \
  ca_file="/vault/config/vault_ca.crt"

