#!/bin/bash
set -euo pipefail

export VAULT_C2_S1_DNS=vault_c2_s1
export VAULT_INIT_OUTPUT=vault_c2.json
export VAULT_SKIP_VERIFY=true

# Init vault_c2_s1
tput setaf 11 && echo "*** Init vault_c2_s1"
export VAULT_ADDR=https://localhost:28201
sleep 5
vault operator init -format=json -n 1 -t 1 > ${VAULT_INIT_OUTPUT}

export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')
tput setaf 11 && echo "*** Root VAULT TOKEN is: $VAULT_TOKEN"

# Unseal vault_c2_s1
tput setaf 11 && echo "*** Unseal vault_c2_s1"
export VAULT_ADDR=https://localhost:28201

export unseal_key=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.unseal_keys_b64[0]')
vault operator unseal ${unseal_key}

sleep 5

# Join vault_c2_s2
tput setaf 11 && echo "*** Join vault_c2_s2"
export VAULT_ADDR=https://localhost:28202
vault operator raft join -leader-ca-cert=@../vault_c2/vault_c2_s2/vault_ca.crt https://${VAULT_C2_S1_DNS}:8200

# Unseal vault_c2_s2
tput setaf 11 && echo "*** Unseal vault_c2_s2"
vault operator unseal ${unseal_key}

# Join vault_c2_s3
tput setaf 11 && echo "*** Join vault_c2_s3"
export VAULT_ADDR=https://localhost:28203
vault operator raft join -leader-ca-cert=@../vault_c2/vault_c2_s3/vault_ca.crt https://${VAULT_C2_S1_DNS}:8200

# Unseal vault_c2_s3
tput setaf 11 && echo "*** Unseal vault_c2_s3"
vault operator unseal ${unseal_key}

# Reset vault addr and add vault token
export VAULT_ADDR=https://localhost:28201

sleep 5

tput setaf 11 && echo "*** Vault_C2 Cluster members"
vault operator members

export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')
#vault token lookup