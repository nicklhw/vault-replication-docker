#!/bin/bash

set -euo pipefail

# Setup VAULT_ADDR and VAULT_TOKEN
export VAULT_INIT_OUTPUT=vault_c1.json
export VAULT_ADDR=http://localhost:18201
export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')

vault policy write dr-secondary-promotion ./dr_promotion_policy.hcl

vault write auth/token/roles/failover-handler \
    allowed_policies=dr-secondary-promotion \
    orphan=true \
    renewable=false \
    token_type=batch

vault token create -role=failover-handler -format=json -ttl=24h > dr_token.json

# Bring down primary cluster
docker pause vault_c1_s1
docker pause vault_c1_s2
docker pause vault_c1_s3

# Promote the DR to primary
export VAULT_INIT_OUTPUT=vault_c2.json
export VAULT_ADDR=http://localhost:28201
export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')

vault write sys/replication/dr/secondary/promote dr_operation_token=$(cat dr_token.json | jq -r '.auth.client_token')

