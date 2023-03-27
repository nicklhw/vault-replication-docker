#!/bin/bash

set -euo pipefail

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
tput setaf 12 && echo "############## Pause Vault_C1 cluster ##############"
tput sgr0
docker pause vault_c1_s1
docker pause vault_c1_s2
docker pause vault_c1_s3

sleep 5

# Generate DR operation token
tput setaf 12 && echo "############## Generate DR operation token for Vault C2 ##############"
vault operator generate-root -dr-token -init -format=json > dr_ops_token_c2.json

vault operator generate-root \
  -dr-token \
  -format=json \
  -nonce=$(cat dr_ops_token_c2.json | jq -r '.nonce') \
  ${VAULT_UNSEAL_KEY} > dr_ops_token_encoded_c2.json

vault operator generate-root \
  -dr-token \
  -format=json \
  -otp=$(cat dr_ops_token_c2.json | jq -r '.otp') \
  -decode=$(cat dr_ops_token_encoded_c2.json | jq -r '.encoded_token') > dr_token_c2.json

# Promote DR Secondary
tput setaf 12 && echo "############## Promote Vault C2 as DR Primary ##############"
vault write \
  sys/replication/dr/secondary/promote \
  primary_cluster_addr="https://haproxy_c2:8201" \
  dr_operation_token=$(cat dr_token_c2.json | jq -r '.token')

sleep 5

# The next steps to demote/promote PR Primary and then update the PR Secondary
# is only necessary when the PR Primary nodes are not directly routable from
# the PR Secondary nodes. Otherwise, the PR Secondary will connect to the new Primary
# automatically. This is made possible because the heartbeat info between the
# Primary and the PR secondary contains a list of all known DR clusters.

tput setaf 12 && echo "############## Demote Vault C2 Performance Primary ##############"
vault write -f \
  sys/replication/performance/primary/demote

tput setaf 12 && echo "############## Promote Vault C2 as Performance Primary ##############"
vault write \
  sys/replication/performance/secondary/promote \
  primary_cluster_addr="https://haproxy_c2:8201" \

vault write \
  sys/replication/performance/primary/secondary-token \
  -format=json id="pr_secondary" > pr_activation_c3.json

tput setaf 12 && echo "############## Update Vault C3 PR Primary ##############"
export VAULT_ADDR=https://localhost:9203
export VAULT_TOKEN=$(vault login -method=userpass username=admin password=passw0rd -format=json | jq -r '.auth.client_token')

vault write \
  sys/replication/performance/secondary/update-primary \
  token=$(cat pr_activation_c3.json | jq -r '.wrap_info.token') \
  primary_api_addr="https://haproxy_c2" \
  ca_file="/vault/config/vault_ca.crt"

# Re-establish PR Secondary connection to the new DR Primary
#cat ./haproxy_int_dr.cfg > ../haproxy_int/haproxy.cfg

#docker restart haproxy_int



