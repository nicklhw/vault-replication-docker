#!/bin/bash

# This scripts detects the IP address for vault servers, writes it to a config file, then restarts Vault
for server in vault_c1_s1 vault_c1_s2 vault_c1_s3
do
    export ip=$(docker inspect ${server} -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
    echo "IP address of ${server}: ${ip}"
    echo "Writing config file: ../vault_c1/${server}/addr.hcl"
cat <<EOF > ../vault_c1/${server}/addr.hcl
api_addr = "http://${ip}:8200"
cluster_addr = "https://${ip}:8201"
EOF
    echo "starting ${server}"
    docker restart $server
done
