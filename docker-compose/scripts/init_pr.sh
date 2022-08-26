#!/bin/bash

set -euo pipefail

# Enable Performance Primary Replication
echo "Enable Performance Primary Replication"
export VAULT_INIT_OUTPUT=vault_c1.json
export VAULT_ADDR=http://localhost:18201
export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')

vault write -f sys/replication/performance/primary/enable

vault write sys/replication/performance/primary/secondary-token -format=json id="secondary" > pr_activation.json

sleep 5

# Enable Performance Secondary Replication
echo "Enable Performance Secondary Replication"
export VAULT_INIT_OUTPUT=vault_c3.json
export VAULT_ADDR=http://localhost:38201
export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')

vault write sys/replication/performance/secondary/enable token=$(cat pr_activation.json | jq -r '.wrap_info.token')