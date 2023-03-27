#!/bin/bash

set -euo pipefail

# Bring up primary cluster
tput setaf 12 && echo "############## Unpause Vault_C1 cluster ##############"
tput sgr0
docker unpause vault_c1_s1
docker unpause vault_c1_s2
docker unpause vault_c1_s3

sleep 10

export VAULT_SKIP_VERIFY=true

tput setaf 12 && echo "############## Demote Vault_C1 to secondary ##############"
export VAULT_ADDR=https://localhost:9201
export VAULT_INIT_OUTPUT=vault_c1.json
export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')
vault write -f sys/replication/dr/primary/demote

tput setaf 12 && echo "############## Update Haproxy_C1 health check config to allow routing to DR cluster ##############"
cat ./haproxy_c1_dr.cfg > ../haproxy_c1/haproxy.cfg

docker restart haproxy_c1

sleep 10

tput setaf 12 && echo "############## Generate secondary activation token from Vault_C2 ##############"
export VAULT_ADDR=https://localhost:9202
export VAULT_DR_ACTIVATION_TOKEN=$(vault write sys/replication/dr/primary/secondary-token -format=json id="dr_secondary" | jq -r '.wrap_info.token')

tput setaf 12 && echo "############## Generate DR operation token from Vault_C1 ##############"
export VAULT_ADDR=https://localhost:9201
export VAULT_UNSEAL_KEY=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.unseal_keys_b64[0]')

vault operator generate-root -dr-token -init -format=json > dr_ops_token_c1.json

vault operator generate-root \
  -dr-token \
  -format=json \
  -nonce=$(cat dr_ops_token_c1.json | jq -r '.nonce') \
  ${VAULT_UNSEAL_KEY} > dr_ops_token_encoded_c1.json

vault operator generate-root \
  -dr-token \
  -format=json \
  -otp=$(cat dr_ops_token_c1.json | jq -r '.otp') \
  -decode=$(cat dr_ops_token_encoded_c1.json | jq -r '.encoded_token') > dr_token_c1.json

# Update Vault_C1 as DR Secondary
tput setaf 12 && echo "############## Update Vault_C1 as DR Secondary ##############"
vault write \
  sys/replication/dr/secondary/update-primary \
  dr_operation_token=$(cat dr_token_c1.json | jq -r '.token') \
  token=${VAULT_DR_ACTIVATION_TOKEN} \
  ca_file="/vault/config/vault_ca.crt" \
  primary_api_addr="https://haproxy_c2"