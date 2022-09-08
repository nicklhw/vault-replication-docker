#!/bin/bash
set -euo pipefail

# https://devopscube.com/create-self-signed-certificates-openssl/

echo "######### Create Vault CA #########"

openssl req -x509 \
            -sha256 -days 1024 \
            -nodes \
            -newkey rsa:2048 \
            -subj "/CN=demo.hashicorp.com/C=CA/L=Toronto" \
            -keyout vault_ca.key -out vault_ca.crt

echo "######### Create Vault C1 CSR #########"

openssl genrsa -out vault_c1.key 2048

openssl req -new -sha256 \
    -key vault_c1.key \
    -subj "/C=CA/ST=Ontario/O=HashiCorp/CN=vault.c1.hashicorp.com" \
    -reqexts SAN \
    -config <(cat /etc/ssl/openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:localhost,DNS:127.0.0.1,DNS:vault_c1_s1,DNS:vault_c1_s2,DNS:vault_c1_s3")) \
    -out vault_c1.csr

openssl req -in vault_c1.csr -noout -text

echo "######### Create Vault C1 Certificate #########"

openssl x509 -req \
             -extfile <(printf "subjectAltName=DNS:localhost,DNS:127.0.0.1,DNS:vault_c1_s1,DNS:vault_c1_s2,DNS:vault_c1_s3") \
             -in vault_c1.csr \
             -CA vault_ca.crt \
             -CAkey vault_ca.key \
             -CAcreateserial \
             -out vault_c1.crt \
             -days 500 \
             -sha256

openssl x509 -in vault_c1.crt -text -noout

cp vault_c1.crt vault_c1.key vault_ca.crt vault_ca.key ../docker-compose/vault_c1/vault_c1_s1
cp vault_c1.crt vault_c1.key vault_ca.crt vault_ca.key ../docker-compose/vault_c1/vault_c1_s2
cp vault_c1.crt vault_c1.key vault_ca.crt vault_ca.key ../docker-compose/vault_c1/vault_c1_s3

echo "######### Create Vault c2 CSR #########"

openssl genrsa -out vault_c2.key 2048

openssl req -new -sha256 \
    -key vault_c2.key \
    -subj "/C=CA/ST=Ontario/O=HashiCorp/CN=vault.c2.hashicorp.com" \
    -reqexts SAN \
    -config <(cat /etc/ssl/openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:localhost,DNS:127.0.0.1,DNS:vault_c2_s1,DNS:vault_c2_s2,DNS:vault_c2_s3")) \
    -out vault_c2.csr

openssl req -in vault_c2.csr -noout -text

echo "######### Create Vault c2 Certificate #########"

openssl x509 -req \
             -extfile <(printf "subjectAltName=DNS:localhost,DNS:127.0.0.1,DNS:vault_c2_s1,DNS:vault_c2_s2,DNS:vault_c2_s3") \
             -in vault_c2.csr \
             -CA vault_ca.crt \
             -CAkey vault_ca.key \
             -CAcreateserial \
             -out vault_c2.crt \
             -days 500 \
             -sha256

openssl x509 -in vault_c2.crt -text -noout

cp vault_c2.crt vault_c2.key vault_ca.crt vault_ca.key ../docker-compose/vault_c2/vault_c2_s1
cp vault_c2.crt vault_c2.key vault_ca.crt vault_ca.key ../docker-compose/vault_c2/vault_c2_s2
cp vault_c2.crt vault_c2.key vault_ca.crt vault_ca.key ../docker-compose/vault_c2/vault_c2_s3

echo "######### Create Vault c3 CSR #########"

openssl genrsa -out vault_c3.key 2048

openssl req -new -sha256 \
    -key vault_c3.key \
    -subj "/C=CA/ST=Ontario/O=HashiCorp/CN=vault.c3.hashicorp.com" \
    -reqexts SAN \
    -config <(cat /etc/ssl/openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:localhost,DNS:127.0.0.1,DNS:vault_c3_s1,DNS:vault_c3_s2,DNS:vault_c3_s3")) \
    -out vault_c3.csr

openssl req -in vault_c3.csr -noout -text

echo "######### Create Vault c3 Certificate #########"

openssl x509 -req \
             -extfile <(printf "subjectAltName=DNS:localhost,DNS:127.0.0.1,DNS:vault_c3_s1,DNS:vault_c3_s2,DNS:vault_c3_s3") \
             -in vault_c3.csr \
             -CA vault_ca.crt \
             -CAkey vault_ca.key \
             -CAcreateserial \
             -out vault_c3.crt \
             -days 500 \
             -sha256

openssl x509 -in vault_c3.crt -text -noout

cp vault_c3.crt vault_c3.key vault_ca.crt vault_ca.key ../docker-compose/vault_c3/vault_c3_s1
cp vault_c3.crt vault_c3.key vault_ca.crt vault_ca.key ../docker-compose/vault_c3/vault_c3_s2
cp vault_c3.crt vault_c3.key vault_ca.crt vault_ca.key ../docker-compose/vault_c3/vault_c3_s3