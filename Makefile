SHELL := /bin/bash
PWD := $(shell pwd)

ifeq (, $(shell which docker))
$(error Docker not found)
endif

DOCKER := httpd
NAME := web-serve-blog

.PHONY: exit \
		clean \
		pull \
		stop \
		build \
		resume \
		deploy \
		serve \ 
		rebuild

all: serve

exit:
	$(error Exiting Makefile)

clean:
	@rm -rf public
	@mkdir public
	@touch public/.gitkeep

pull:
	@docker pull ${DOCKER}

stop: $(if $(shell docker ps --filter "name=${NAME}" --format "{{.ID}}") , ,exit)
	@docker stop $(shell docker ps --filter "name=${NAME}" --format "{{.ID}}")

build:
	@./build.sh 

resume:
	@$(MAKE) -C resume

deploy:
	@./deploy.sh

serve: $(if $(shell docker images --format "{{.Repository}}" | grep ${DOCKER}), , pull)
	@docker run --rm \
			   --detach \
			   --name ${NAME} \
			   -p 8080:80 \
			   -v ${PWD}/public:/usr/local/apache2/htdocs \
			   ${DOCKER}:latest

rebuild: stop serve build
