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
    -config <(cat /etc/ssl/openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:localhost,IP:127.0.0.1,DNS:vault_c1_s1,DNS:vault_c1_s2,DNS:vault_c1_s3,DNS:haproxy_c1,DNS:haproxy_int,DNS:haproxy_glb")) \
    -out vault_c1.csr

openssl req -in vault_c1.csr -noout -text

echo "######### Create Vault C1 Certificate #########"

openssl x509 -req \
             -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1,DNS:vault_c1_s1,DNS:vault_c1_s2,DNS:vault_c1_s3,DNS:haproxy_c1,DNS:haproxy_int,DNS:haproxy_glb") \
             -in vault_c1.csr \
             -CA vault_ca.crt \
             -CAkey vault_ca.key \
             -CAcreateserial \
             -out vault_c1.crt \
             -days 500 \
             -sha256

openssl x509 -in vault_c1.crt -text -noout

echo "######### Create Vault C1 Certificate Chain #########"

cat vault_c1.crt vault_ca.crt > vault_c1_chain.crt

cp vault_c1_chain.crt vault_ca.crt vault_c1.key ../docker-compose/vault_c1/vault_c1_s1
cp vault_c1_chain.crt vault_ca.crt vault_c1.key ../docker-compose/vault_c1/vault_c1_s2
cp vault_c1_chain.crt vault_ca.crt vault_c1.key ../docker-compose/vault_c1/vault_c1_s3

openssl x509 -noout -subject -issuer -in vault_c1_chain.crt

echo "######### Create Vault c2 CSR #########"

openssl genrsa -out vault_c2.key 2048

openssl req -new -sha256 \
    -key vault_c2.key \
    -subj "/C=CA/ST=Ontario/O=HashiCorp/CN=vault.c2.hashicorp.com" \
    -reqexts SAN \
    -config <(cat /etc/ssl/openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:localhost,IP:127.0.0.1,DNS:vault_c2_s1,DNS:vault_c2_s2,DNS:vault_c2_s3,DNS:haproxy_c2,DNS:haproxy_int,DNS:haproxy_glb")) \
    -out vault_c2.csr

openssl req -in vault_c2.csr -noout -text

echo "######### Create Vault c2 Certificate #########"

openssl x509 -req \
             -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1,DNS:vault_c2_s1,DNS:vault_c2_s2,DNS:vault_c2_s3,DNS:haproxy_c2,DNS:haproxy_int,DNS:haproxy_glb") \
             -in vault_c2.csr \
             -CA vault_ca.crt \
             -CAkey vault_ca.key \
             -CAcreateserial \
             -out vault_c2.crt \
             -days 500 \
             -sha256

openssl x509 -in vault_c2.crt -text -noout

echo "######### Create Vault C2 Certificate Chain #########"

cat vault_c2.crt vault_ca.crt > vault_c2_chain.crt

cp vault_c2_chain.crt vault_ca.crt vault_c2.key ../docker-compose/vault_c2/vault_c2_s1
cp vault_c2_chain.crt vault_ca.crt vault_c2.key ../docker-compose/vault_c2/vault_c2_s2
cp vault_c2_chain.crt vault_ca.crt vault_c2.key ../docker-compose/vault_c2/vault_c2_s3

openssl x509 -noout -subject -issuer -in vault_c2_chain.crt

echo "######### Create Vault c3 CSR #########"

openssl genrsa -out vault_c3.key 2048

openssl req -new -sha256 \
    -key vault_c3.key \
    -subj "/C=CA/ST=Ontario/O=HashiCorp/CN=vault.c3.hashicorp.com" \
    -reqexts SAN \
    -config <(cat /etc/ssl/openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:localhost,IP:127.0.0.1,DNS:vault_c3_s1,DNS:vault_c3_s2,DNS:vault_c3_s3,DNS:haproxy_c3,DNS:haproxy_int,DNS:haproxy_glb")) \
    -out vault_c3.csr

openssl req -in vault_c3.csr -noout -text

echo "######### Create Vault c3 Certificate #########"

openssl x509 -req \
             -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1,DNS:vault_c3_s1,DNS:vault_c3_s2,DNS:vault_c3_s3,DNS:haproxy_c3,DNS:haproxy_int,DNS:haproxy_glb") \
             -in vault_c3.csr \
             -CA vault_ca.crt \
             -CAkey vault_ca.key \
             -CAcreateserial \
             -out vault_c3.crt \
             -days 500 \
             -sha256

openssl x509 -in vault_c3.crt -text -noout

echo "######### Create Vault C3 Certificate Chain #########"

cat vault_c3.crt vault_ca.crt > vault_c3_chain.crt

cp vault_c3_chain.crt vault_ca.crt vault_c3.key ../docker-compose/vault_c3/vault_c3_s1
cp vault_c3_chain.crt vault_ca.crt vault_c3.key ../docker-compose/vault_c3/vault_c3_s2
cp vault_c3_chain.crt vault_ca.crt vault_c3.key ../docker-compose/vault_c3/vault_c3_s3

openssl x509 -noout -subject -issuer -in vault_c3_chain.crt

echo "######### Create Vault c4 CSR #########"

openssl genrsa -out vault_c4.key 2048

openssl req -new -sha256 \
    -key vault_c4.key \
    -subj "/C=CA/ST=Ontario/O=HashiCorp/CN=vault.c4.hashicorp.com" \
    -reqexts SAN \
    -config <(cat /etc/ssl/openssl.cnf <(printf "\n[SAN]\nsubjectAltName=DNS:localhost,IP:127.0.0.1,DNS:vault_c4_s1,DNS:vault_c4_s2,DNS:vault_c4_s3,DNS:haproxy_c4,DNS:haproxy_int,DNS:haproxy_glb")) \
    -out vault_c4.csr

openssl req -in vault_c4.csr -noout -text

echo "######### Create Vault c4 Certificate #########"

openssl x509 -req \
             -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1,DNS:vault_c4_s1,DNS:vault_c4_s2,DNS:vault_c4_s3,DNS:haproxy_c4,DNS:haproxy_int,DNS:haproxy_glb") \
             -in vault_c4.csr \
             -CA vault_ca.crt \
             -CAkey vault_ca.key \
             -CAcreateserial \
             -out vault_c4.crt \
             -days 500 \
             -sha256

openssl x509 -in vault_c4.crt -text -noout

echo "######### Create Vault C4 Certificate Chain #########"

cat vault_c4.crt vault_ca.crt > vault_c4_chain.crt

cp vault_c4_chain.crt vault_ca.crt vault_c4.key ../docker-compose/vault_c4/vault_c4_s1
cp vault_c4_chain.crt vault_ca.crt vault_c4.key ../docker-compose/vault_c4/vault_c4_s2
cp vault_c4_chain.crt vault_ca.crt vault_c4.key ../docker-compose/vault_c4/vault_c4_s3

openssl x509 -noout -subject -issuer -in vault_c4_chain.crt