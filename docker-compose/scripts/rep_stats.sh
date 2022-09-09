#!/bin/bash

#set -euo pipefail

export VAULT_SKIP_VERIFY=true

echo "############## VAULT C1 REPLICATION STATUS ##############"
export VAULT_ADDR=https://localhost:9201
export VAULT_C1_TOKEN=$(vault login -method=userpass username=tester password=changeme -format=json | jq -r '.auth.client_token')
vault read sys/replication/status -format=json

echo "############## VAULT C2 REPLICATION STATUS ##############"
export VAULT_ADDR=https://localhost:9202
vault read sys/replication/dr/status -format=json

echo "############## VAULT C3 REPLICATION STATUS ##############"
export VAULT_ADDR=https://localhost:9203
export VAULT_C3_TOKEN=$(vault login -method=userpass username=tester password=changeme -format=json | jq -r '.auth.client_token')
vault read sys/replication/status -format=json

echo "############## VAULT C4 REPLICATION STATUS ##############"
export VAULT_ADDR=https://localhost:9204
vault read sys/replication/dr/status -format=json
