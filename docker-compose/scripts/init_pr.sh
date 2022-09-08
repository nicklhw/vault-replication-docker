#!/bin/bash

set -euo pipefail

# Enable Performance Primary Replication
echo "Enable Performance Primary Replication"
export VAULT_SKIP_VERIFY=true
export VAULT_INIT_OUTPUT=vault_c1.json
export VAULT_ADDR=https://localhost:9201
export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')

vault write -f sys/replication/performance/primary/enable primary_cluster_addr="https://haproxy_int:18201"

sleep 5

vault write sys/replication/performance/primary/secondary-token -format=json id="pr_secondary" > pr_activation.json

sleep 5

# Enable Performance Secondary Replication
echo "Enable Performance Secondary Replication"
export VAULT_INIT_OUTPUT=vault_c3.json
export VAULT_ADDR=https://localhost:9203
export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')

vault write \
  sys/replication/performance/secondary/enable \
  primary_api_addr="https://haproxy_int:18200" \
  token=$(cat pr_activation.json | jq -r '.wrap_info.token') \
  ca_file="/vault/config/vault_ca.crt"