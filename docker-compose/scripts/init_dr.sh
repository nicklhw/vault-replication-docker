#!/bin/bash

set -euo pipefail

# Enable DR Primary Replication
echo "Enable DR Primary Replication"
export VAULT_INIT_OUTPUT=vault_c1.json
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')

vault write -f sys/replication/dr/primary/enable

vault write sys/replication/dr/primary/secondary-token -format=json id="secondary" > dr_activation.json

sleep 5

# Enable DR Secondary Replication
echo "Enable DR Secondary Replication"
export VAULT_INIT_OUTPUT=vault_c2.json
export VAULT_ADDR=http://localhost:38200
export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')

vault write sys/replication/dr/secondary/enable token=$(cat dr_activation.json | jq -r '.wrap_info.token')

