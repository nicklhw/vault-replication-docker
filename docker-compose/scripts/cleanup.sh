#!/bin/bash

# This script will clean up locally provisioned resources
rm -f vault_c1.json
rm -f vault_c2.json
rm -f dr_activation.json
rm -r dr_token.json
cd ../ && docker-compose down