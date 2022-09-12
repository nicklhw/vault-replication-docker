.DEFAULT_GOAL := info

all: clean up-detach init

.PHONY: clean up up-detach init info admin

info:
	$(info Targets are: all, up, up-detach, init, clean. Run all to execute them in order.)
	$(info up will block and docker compose in foreground, up-detach will run docker compose in background.)

up:
	cd docker-compose \
	  && docker-compose up

up-detach:
	cd docker-compose \
	  && docker-compose up --detach

init:
	cd docker-compose/scripts \
	  && ./init_c1.sh \
	  && ./init_c2.sh \
	  && ./init_c3.sh \
	  && ./init_c4.sh \
	  && ./init_dr_c2.sh \
	  && ./init_pr_c3.sh \
	  && sleep 10 \
	  && ./init_dr_c4.sh \
	  && sleep 10 \
	  && ./rep_stats.sh

clean:
	cd docker-compose/scripts && ./cleanup.sh

secret:
	cd terraform && terraform init && terraform apply -var-file="secrets.tfvars" --auto-approve

clean-secret:
	cd terraform && terraform destroy -var-file="secrets.tfvars" --auto-approve

show-metadata:
	export VAULT_ADDR=http://localhost:18201 \
	&& export VAULT_TOKEN=root \
	&& vault kv metadata get -format=json secret/foo

show-members:
	export VAULT_ADDR=http://localhost:18201 \
	&& export VAULT_TOKEN=$$(cat docker-compose/scripts/vault.txt | jq -r '.root_token') \
	&& vault operator raft list-peers

ui: ui-c1 ui-c2 ui-c3 ui-c4

ui-c1:
	open https://localhost:9201/ui/vault/replication

ui-c2:
	open https://localhost:9202/ui/vault/replication

ui-c3:
	open https://localhost:9203/ui/vault/replication

ui-c4:
	open https://localhost:9204/ui/vault/replication

token-c1:
	cat docker-compose/scripts/vault_c1.json | jq -r '.root_token' | pbcopy

token-c2:
	cat docker-compose/scripts/vault_c2.json | jq -r '.root_token' | pbcopy

token-c3:
	cat docker-compose/scripts/vault_c3.json | jq -r '.root_token' | pbcopy

token-c4:
	cat docker-compose/scripts/vault_c4.json | jq -r '.root_token' | pbcopy

promote-dr-c2:
	cd docker-compose/scripts \
	  && ./promote_dr_c2.sh \
	  && sleep 10 \
	  && ./rep_stats.sh

demote-primary-c1:
	cd docker-compose/scripts \
	  && ./demote_primary_c1.sh \
	  && sleep 10 \
	  && ./rep_stats.sh

rep-status:
	cd docker-compose/scripts \
	  && ./rep_stats.sh