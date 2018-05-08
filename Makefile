.PHONEY: all start stop snap rollback

all: help

help:    ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

start:
	@vagrant up haproxy ucp-1 dtr-1 worker-1 worker-2

stop:
	@vagrant halt

manager:
	@vagrant up ucp-1

proxy:
	@vagrant up haproxy
#get: ## get all dependencies
#	@ansible-galaxy install -r ansible/requirements.yml -p ansible/roles

#snap: ## snapshot all vms
#	./scripts/snapshot.sh

#rollback: ## rollback to the previous snapshot
#	./scripts/rollback.sh

build:
	@vagrant provision

#etc/:
#	./scripts/etc-setup.sh

# test: ## quick env reachability test
# 	@ansible all -m ping

destroy:
	@echo "Tear down environment..."
	@vagrant destroy -f
