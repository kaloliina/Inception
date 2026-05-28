DOCKER_COMPOSE_FILE := ./srcs/docker-compose.yml
ENV_FILE := ./srcs/.env
DATA_DIR := $(HOME)/data
WORDPRESS_DATA_DIR := $(DATA_DIR)/wordpress
MARIADB_DATA_DIR := $(DATA_DIR)/mariadb

name = inception

all: create_dirs make_dir_up

build: create_dirs make_dir_up_build

down:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) down

re: down create_dirs make_dir_up_build

clean: down
	@docker system prune -a
	@sudo rm -rf $(WORDPRESS_DATA_DIR)/*
	@sudo rm -rf $(MARIADB_DATA_DIR)/*

fclean: down
	@docker system prune --all --force --volumes
	@docker network prune --force
	@docker volume prune --force

logs:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) logs -fclean

create_dirs:
	@mkdir -p $(WORDPRESS_DATA_DIR)
	@mkdir -p $(MARIADB_DATA_DIR)

make_dir_up:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d

make_dir_up_build:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d --build

