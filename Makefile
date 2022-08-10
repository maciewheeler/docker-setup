.PHONY: help
.DEFAULT_GOAL: help

CONTAINER_TAG=name_here
#ECR_REPOSITORY=ecr_here
STACK_NAME=$(CONTAINER_TAG)

# Environment Variables for local running
ENV_LIST='\
	SNOWFLAKE_USER=$(SNOWFLAKE_USER)\n\
	SNOWFLAKE_ACCOUNT=$(SNOWFLAKE_ACCOUNT)\n\
	SNOWFLAKE_PASSWORD=$(SNOWFLAKE_PASSWORD)\n\
	SNOWFLAKE_DATABASE=$(SNOWFLAKE_DATABASE)\n\
	SNOWFLAKE_SCHEMA=$(SNOWFLAKE_SCHEMA)\n\
	SNOWFLAKE_WAREHOUSE=$(SNOWFLAKE_WAREHOUSE)\n\
	SNOWFLAKE_ROLE=$(SNOWFLAKE_ROLE)\n\
	S3_STAGE=$(S3_STAGE)\n\
	S3_BUCKET=$(S3_BUCKET)\n\
	AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID)\n\
	AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)'

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?##"; \
	printf "\n\
	Usage:\n  \
	make \033[36m<target>\033[0m\n\n\
	Targets:\n"}; \
	{printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2}'

docker-clean-unused: ## Remove unused docker resources
	@echo "Deleting all unused Docker containers."
	docker system prune --all --force --volumes

docker-clean-all: ## Remove all docker resources
	@echo "Deleting *ALL* Docker containers, running or not!"
	docker container stop $(docker container ls --all --quiet) && docker system prune --all --force --volumes

print_env_req: ## Print environment variables required for execution
	@echo "-----"
	@echo "Environment Variables in Bash_Profile Required:"
	@echo "SNOWFLAKE_PASSWORD"
	@echo "SNOWFLAKE_USER"
	@echo "SNOWFLAKE_ROLE"
	@echo "SNOWFLAKE_DATABASE"
	@echo "SNOWFLAKE_SCHEMA"
	@echo "SNOWFLAKE_WAREHOUSE"
	@echo "AWS_ACCESS_KEY_ID"
	@echo "AWS_SECRET_ACCESS_KEY"
	@echo "-----"

env-create: ## Create env file for docker [optional: print=false]
	@printf "\nCreating env.list file containing environment variables.\n"
	@printf $(ENV_LIST) > env.list

build: ## Build docker container to standardize environment and run tests
	@echo "-----"
	@echo "Building container and tagging it $(CONTAINER_TAG)."
	@docker run \
	    -w /workspace \
		-v $(PWD):/workspace \
	    --env-file ./env.list \
        amazon/aws-cli s3 cp s3://
	@docker build --tag $(CONTAINER_TAG) .
	@echo "Cleaning... removing ./packages folder"
	@rm -r ./packages

jupyter: ## Run Jupyter [J=lab]
	@printf "\033[36mStarting the Jupyter $(J) server\033[0m\n"
	@docker run \
	--publish 8888:8888 \
	-w /workspace \
	--volume $$(pwd):/workspace \
	--env-file ./env.list \
	--detach $(CONTAINER_TAG) jupyter lab
	@echo "Go to http://localhost:8888/"

bash: ## Enter Docker environment via Bash shell
	docker run --interactive --tty \
	--env-file ./env.list \
	$(CONTAINER_TAG) /bin/bash

stop: ## Stop running containers
	docker container stop $$(docker ps -q)
