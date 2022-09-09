#!/bin/bash

set -euo pipefail

# Setup VAULT_ADDR and VAULT_TOKEN
export VAULT_SKIP_VERIFY=true
export VAULT_INIT_OUTPUT=vault_c1.json
export VAULT_ADDR=https://localhost:9202
export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')
export VAULT_UNSEAL_KEY=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.unseal_keys_b64[0]')

#vault policy write dr-secondary-promotion ./dr_promotion_policy.hcl
#
#vault write auth/token/roles/failover-handler \
#    allowed_policies=dr-secondary-promotion \
#    orphan=true \
#    renewable=false \
#    token_type=batch
#
#vault token create -role=failover-handler -format=json -ttl=24h > dr_token.json

# Bring down primary cluster
echo "Stopping Vault_C1 cluster"
docker stop vault_c1_s1
docker stop vault_c1_s2
docker stop vault_c1_s3

# Generate DR operation token
echo "Generate DR operation token"
vault operator generate-root -dr-token -init -format=json > dr_ops_token_init.json

vault operator generate-root \
  -dr-token \
  -format=json \
  -nonce=$(cat dr_ops_token_init.json | jq -r '.nonce') \
  ${VAULT_UNSEAL_KEY} > dr_ops_token_encoded.json

vault operator generate-root \
  -dr-token \
  -format=json \
  -otp=$(cat dr_ops_token_init.json | jq -r '.otp') \
  -decode=$(cat dr_ops_token_encoded.json | jq -r '.encoded_token') > dr_token.json

# Promote DR Secondary
vault write sys/replication/dr/secondary/promote dr_operation_token=$(cat dr_token.json | jq -r '.token')

# Re-establish PR Secondary connection to the new DR Primary
cat ./haproxy_int_dr.cfg > ../haproxy_int/haproxy.cfg

docker restart haproxy_int

