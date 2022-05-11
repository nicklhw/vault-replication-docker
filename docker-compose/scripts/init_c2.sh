#!/bin/bash
set -euo pipefail

# Docker compose IP address fix
for server in vault_c2_s1 vault_c2_s2 vault_c2_s3
do
    export ip=$(docker inspect ${server} -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
    echo "IP address of ${server}: ${ip}"
    echo "Writing config file: ../vault_c2/${server}/addr.hcl"
cat <<EOF > ../vault_c2/${server}/addr.hcl
api_addr = "http://${ip}:8200"
cluster_addr = "https://${ip}:8201"
EOF
    echo "starting ${server}"
    docker restart $server
done

export VAULT_c2_S1_IP=$(docker inspect vault_c2_s1 -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
export VAULT_INIT_OUTPUT=vault_c2.txt

# Init vault_c2_s1
echo "Init and unseal vault_c2_s1"
export VAULT_ADDR=http://localhost:38200
sleep 5
vault operator init -format=json -n 1 -t 1 > ${VAULT_INIT_OUTPUT}

export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')
echo "Root VAULT TOKEN is: $VAULT_TOKEN"

# Unseal vault_c2_s1
echo "Unseal vault_c2_s1"
export VAULT_ADDR=http://localhost:38200

export unseal_key=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.unseal_keys_b64[0]')
vault operator unseal ${unseal_key}

sleep 5

# Join vault_c2_s2
echo "Join vault_c2_s2"
export VAULT_ADDR=http://localhost:48200
vault operator raft join http://${VAULT_c2_S1_IP}:8200

# Unseal vault_c2_s2
echo "Unseal vault_c2_s2"
vault operator unseal ${unseal_key}

# Join vault_c2_s3
echo "Join vault_c2_s3"
export VAULT_ADDR=http://localhost:58200
vault operator raft join http://${VAULT_c2_S1_IP}:8200

# Unseal vault_c2_s3
echo "Unseal vault_c2_s3"
vault operator unseal ${unseal_key}

# Reset vault addr and add vault token
export VAULT_ADDR=http://localhost:38200

sleep 5

echo "*** Cluster members ***"
vault operator members

export VAULT_TOKEN=$(cat ${VAULT_INIT_OUTPUT} | jq -r '.root_token')
#vault token lookup

echo "*** Please Run: export VAULT_TOKEN=${VAULT_TOKEN}"