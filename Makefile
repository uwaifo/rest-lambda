
FUNCTION := $(shell basename "$(PWD)")
# get the latest commit hash in the short form
COMMIT := $(shell git rev-parse --short HEAD)
RUNTIME  := go1.x
BIN_DIR  := dist
ARCHIVE  := $(addsuffix -$(COMMIT).zip,$(FUNCTION))
FLAGS := -ldflags "-X main.commit=$(COMMIT)"

TABLE_NAME := test-table

# Base AWS CLI docker command
AWS_CLI  := docker run --network host --env-file ~/.localstack/aws.env \
	-v $(PWD):/workdir/ \
	--rm amazon/aws-cli --endpoint-url=http://localhost:4566

.PHONY: help
all: help
help: Makefile
	@echo
	@echo " Choose a command run in "$(PROJECTNAME)":"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo

.DEFAULT_GOAL := help

## build: Builds the Go Lambda function
build: clean
	mkdir -p $(BIN_DIR)
	GOOS=linux GOARCH=amd64 go build $(FLAGS) -o $(BIN_DIR)/$(FUNCTION)
	zip -r9jT $(BIN_DIR)/$(ARCHIVE) $(BIN_DIR)/$(FUNCTION)

## clean: Clean the dist folder
clean:
	rm -f $(BIN_DIR)/$(FUNCTION) $(BIN_DIR)/*.zip tfplan

## install: Execute Terraform 'plan' and 'apply' commands
install: plan apply

## plan: Execute Terraform 'plan' command
plan:
	TF_VAR_function_name=$(FUNCTION) TF_VAR_filename=$(BIN_DIR)/$(ARCHIVE) \
	terraform plan -out=tfplan

## apply: Execute Terraform 'apply' command
apply:
	TF_VAR_function_name=$(FUNCTION) TF_VAR_filename=$(BIN_DIR)/$(ARCHIVE) \
	terraform apply -auto-approve tfplan

## destroy: Execute Terraform 'destroy' command
destroy:
	TF_VAR_function_name=$(FUNCTION) TF_VAR_filename=$(BIN_DIR)/$(ARCHIVE) \
	terraform destroy -auto-approve

## check: Returns AWS info about this Lambda function
check:
	$(AWS_CLI) lambda get-function --function-name $(FUNCTION)

## invoke: Invoke the API
invoke:
	curl http://localhost:4566/restapis/eaeexzippo/stage/_user_request_/demo \
	--header "Content-Type: application/json" \
	--request POST --data '{"username":"xyz","password":"xyz"}'
