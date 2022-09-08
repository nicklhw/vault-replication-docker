#!/bin/bash
set -euo pipefail

export VAULT_C1_S1_DNS=vault_c1_s1
export VAULT_INIT_OUTPUT=vault_c1.json
export VAULT_SKIP_VERIFY=true

# Init vault_c1_s1
echo "Init and unseal vault_c1_s1"
export VAULT_ADDR=https://localhost:18201
sleep 5
vault operator init -format=json -n 1 -t 1 > ${VAULT_INIT_OUTPUT}

export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')
echo "Root VAULT TOKEN is: $VAULT_TOKEN"

# Unseal vault_c1_s1
echo "Unseal vault_c1_s1"
export VAULT_ADDR=https://localhost:18201

export unseal_key=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.unseal_keys_b64[0]')
vault operator unseal ${unseal_key}

sleep 5

# Join vault_c1_s2
echo "Join vault_c1_s2"
export VAULT_ADDR=https://localhost:18202
vault operator raft join -leader-ca-cert=@../vault_c1/vault_c1_s2/vault_ca.crt https://${VAULT_C1_S1_DNS}:8200

# Unseal vault_c1_s2
echo "Unseal vault_c1_s2"
vault operator unseal ${unseal_key}

# Join vault_c1_s3
echo "Join vault_c1_s3"
export VAULT_ADDR=https://localhost:18203
vault operator raft join -leader-ca-cert=@../vault_c1/vault_c1_s3/vault_ca.crt https://${VAULT_C1_S1_DNS}:8200

# Unseal vault_c1_s3
echo "Unseal vault_c1_s3"
vault operator unseal ${unseal_key}

# Reset vault addr and add vault token
export VAULT_ADDR=https://localhost:18201

sleep 5

echo "*** Cluster members ***"
vault operator members

export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')
#vault token lookup

echo "*** Please Run: export VAULT_TOKEN=${VAULT_TOKEN}"

vault policy write admin ./admin_policy.hcl

vault auth enable userpass

vault write auth/userpass/users/tester password="changeme" policies="admin"