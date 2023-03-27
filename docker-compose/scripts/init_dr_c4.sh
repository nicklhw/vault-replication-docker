#!/bin/bash

set -euo pipefail

# Enable DR Primary Replication for Vault C3
tput setaf 12 && echo "############## Enable DR Primary Replication for Vault C3 ##############"
export VAULT_SKIP_VERIFY=true
export VAULT_INIT_OUTPUT=vault_c3.json
export VAULT_ADDR=https://localhost:9203
export VAULT_TOKEN=$(vault login -method=userpass username=admin password=passw0rd -format=json | jq -r '.auth.client_token')

vault write -f sys/replication/dr/primary/enable primary_cluster_addr="https://haproxy_c3:8201"

sleep 5

vault write sys/replication/dr/primary/secondary-token -format=json id="dr_secondary" > dr_activation_c4.json

sleep 5

# Enable DR Secondary Replication
tput setaf 12 && echo "############## Enable DR Secondary Replication for Vault C4 ##############"
export VAULT_INIT_OUTPUT=vault_c4.json
export VAULT_ADDR=https://localhost:9204
export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')

vault write \
  sys/replication/dr/secondary/enable \
  primary_api_addr="https://haproxy_c3" \
  token=$(cat dr_activation_c4.json | jq -r '.wrap_info.token') \
  ca_file="/vault/config/vault_ca.crt"