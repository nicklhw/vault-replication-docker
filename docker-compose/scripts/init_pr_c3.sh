#!/bin/bash

#set -euo pipefail

# Enable Performance Primary Replication
tput setaf 12 && echo "############## Enable Performance Primary Replication for Vault C1 ##############"
export VAULT_SKIP_VERIFY=true
export VAULT_INIT_OUTPUT=vault_c1.json
export VAULT_ADDR=https://localhost:9201
export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')

vault write -f sys/replication/performance/primary/enable primary_cluster_addr="https://haproxy_int:18201"

sleep 5

vault write sys/replication/performance/primary/secondary-token -format=json id="pr_secondary" > pr_activation_c3.json

sleep 5

# Enable Performance Secondary Replication
tput setaf 12 && echo "############## Enable Performance Secondary Replication for Vault C3 ##############"
export VAULT_INIT_OUTPUT=vault_c3.json
export VAULT_ADDR=https://localhost:9203
export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')

vault write \
  sys/replication/performance/secondary/enable \
  primary_api_addr="https://haproxy_int:18200" \
  token=$(cat pr_activation_c3.json | jq -r '.wrap_info.token') \
  ca_file="/vault/config/vault_ca.crt"

# Ensure that all nodes are unsealed
# When replication is enabled, standby nodes loses connection with the active node and thus seals itself

tput setaf 12 && echo "############## Unseal all standby nodes on Vault C3 ##############"

export VAULT_INIT_OUTPUT=vault_c1.json
export VAULT_UNSEAL_KEY=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.unseal_keys_b64[0]')

export VAULT_ADDR=https://localhost:38201
vault operator unseal ${VAULT_UNSEAL_KEY}

sleep 10

export VAULT_ADDR=https://localhost:38202
vault operator unseal ${VAULT_UNSEAL_KEY}

sleep 10

export VAULT_ADDR=https://localhost:38203
vault operator unseal ${VAULT_UNSEAL_KEY}
