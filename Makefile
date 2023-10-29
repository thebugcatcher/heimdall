.PHONY: phx-server

UNAME_S := $(shell uname -s)
DC := $(shell docker-compose --version)

ifeq ($(UNAME_S),Linux)
	docker_compose=sudo docker-compose
else
	docker_compose=docker-compose
endif

start-infra:
ifndef DC
	$(error "docker-compose is not installed")
endif
	$(docker_compose) --file .development/docker-compose.yml up --build -d --remove-orphans


demo:
ifndef DC
	$(error "docker-compose is not installed")
endif
	$(docker_compose) --file .demo/docker-compose.yml up --build --remove-orphans

setup:
ifndef DC
	$(error "docker-compose is not installed")
endif
	$(docker_compose) --file .demo/docker-compose.yml exec web mix ecto.setup

