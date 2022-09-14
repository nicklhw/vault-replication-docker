#!/bin/bash

set -euo pipefail

export VAULT_SKIP_VERIFY=true
export VAULT_ADDR=https://localhost:9201
export VAULT_INIT_OUTPUT=vault_c1.json
export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')
export VAULT_UNSEAL_KEY=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.unseal_keys_b64[0]')

tput setaf 12 && echo "############## Generate DR ops token for Vault_C1 ##############"
vault operator generate-root -dr-token -init -format=json > dr_fb_ops_token_c1.json

vault operator generate-root \
  -dr-token \
  -format=json \
  -nonce=$(cat dr_fb_ops_token_c1.json | jq -r '.nonce') \
  ${VAULT_UNSEAL_KEY} > dr_fb_ops_token_encoded_c1.json

vault operator generate-root \
  -dr-token \
  -format=json \
  -otp=$(cat dr_fb_ops_token_c1.json | jq -r '.otp') \
  -decode=$(cat dr_fb_ops_token_encoded_c1.json | jq -r '.encoded_token') > dr_fb_token_c1.json

tput setaf 12 && echo "############## Promote Vault_C1 as DR Primary ##############"
vault write \
  sys/replication/dr/secondary/promote \
  dr_operation_token=$(cat dr_fb_token_c1.json | jq -r '.token') \
  primary_cluster_addr="https://haproxy_int:18201"

tput setaf 12 && echo "############## Reset DR configuration of Haproxy ##############"
tput sgr0
DIR="$( cd .. && pwd )"
git reset
git checkout ${DIR}/haproxy_int/haproxy.cfg
git checkout ${DIR}/haproxy_c1/haproxy.cfg
docker restart haproxy_c1
docker restart haproxy_int

sleep 10

tput setaf 12 && echo "############## Demote Vault_C2 to secondary ##############"
export VAULT_ADDR=https://localhost:9202
export VAULT_INIT_OUTPUT=vault_c2.json
vault write -f sys/replication/dr/primary/demote

tput setaf 12 && echo "############## Generate secondary activation token from Vault_C1 ##############"
export VAULT_ADDR=https://localhost:9201
export VAULT_DR_ACTIVATION_TOKEN=$(vault write sys/replication/dr/primary/secondary-token -format=json id="dr_secondary" | jq -r '.wrap_info.token')

tput setaf 12 && echo "############## Generate DR operation token for Vault_C2 ##############"
export VAULT_ADDR=https://localhost:9202

vault operator generate-root -dr-token -init -format=json > dr_fb_ops_token_c2.json

vault operator generate-root \
  -dr-token \
  -format=json \
  -nonce=$(cat dr_fb_ops_token_c2.json | jq -r '.nonce') \
  ${VAULT_UNSEAL_KEY} > dr_fb_ops_token_encoded_c2.json

vault operator generate-root \
  -dr-token \
  -format=json \
  -otp=$(cat dr_fb_ops_token_c2.json | jq -r '.otp') \
  -decode=$(cat dr_fb_ops_token_encoded_c2.json | jq -r '.encoded_token') > dr_fb_token_c2.json

tput setaf 12 && echo "############## Update Vault_C2 as DR Secondary ##############"
vault write \
  sys/replication/dr/secondary/update-primary \
  dr_operation_token=$(cat dr_fb_token_c2.json | jq -r '.token') \
  token=${VAULT_DR_ACTIVATION_TOKEN} \
  ca_file="/vault/config/vault_ca.crt" \
  primary_api_addr="https://haproxy_int:18200"
