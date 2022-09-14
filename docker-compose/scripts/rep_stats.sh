#!/bin/bash

#set -euo pipefail

export VAULT_SKIP_VERIFY=true

tput setaf 12 && echo "############## VAULT C1 REPLICATION STATUS ##############"
tput sgr0
export VAULT_ADDR=https://localhost:9201
vault read sys/replication/status -format=json

tput setaf 12 && echo "############## VAULT C2 REPLICATION STATUS ##############"
tput sgr0
export VAULT_ADDR=https://localhost:9202
vault read sys/replication/status -format=json

tput setaf 12 && echo "############## VAULT C3 REPLICATION STATUS ##############"
tput sgr0
export VAULT_ADDR=https://localhost:9203
vault read sys/replication/status -format=json

tput setaf 12 && echo "############## VAULT C4 REPLICATION STATUS ##############"
tput sgr0
export VAULT_ADDR=https://localhost:9204
vault read sys/replication/status -format=json
