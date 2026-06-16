DOCKER_COMPOSE_FILE := ./srcs/docker-compose.yml
DATA_DIR := $(HOME)/data
WORDPRESS_DATA_DIR := $(DATA_DIR)/wordpress
MARIADB_DATA_DIR := $(DATA_DIR)/mariadb

name = inception

all : build

#create dirs, build images, start containers
build:
	@mkdir -p $(WORDPRESS_DATA_DIR)
	@mkdir -p $(MARIADB_DATA_DIR)
	@docker-compose -f $(DOCKER_COMPOSE_FILE) up -d --build

#start already built containers
up:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) up -d

#stop and remove containers, keep volumes and images
down:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) down

#down + remove images and containers
clean: down
	docker system prune -f

#clean + remove volumes + data dirs
fclean: clean
	docker volume rm mariadb wordpress
	docker system prune -af --volumes
	sudo rm -rf $(DATA_DIR)

#fclean + build
re: fclean all

.PHONY: all build up down clean fclean re
