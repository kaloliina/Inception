Developer Documentation:

Prerequisites:
- Virtual Machine with sudo access
- Docker and Docker Compose installed
- Port 443 enabled for nginx.

Git clone the project and navigate to the root of the project.
- MAKE
    - Builds docker images, creates volumes and network, starts all containers.
- MAKE FCLEAN
    - stops and removes everything including data
- MAKE UP
    - uses built images to run the service again.
- MAKE DOWN
    - stops the containers but keeps the data

Checking services
- docker ps : shows running containers and exposed ports
- docker logs <container> : to see logs

- docker volume ls : shows list of volumes
- docker volume inspect <container> : inspect a specific volume
- ls /home/khiidenh/data/mariadb : see mariadb volume data on host
- ls /home/khiidenh/data/wordpress : see wordpress volume data on host

- docker network ls : show networks
- docker network inspect docker-network : to see connected containers

In order to inspect database:
-docker exec -it wordpress wp user list --allow-root
-docker exec -it wordpress wp post list --allow-root

docker exec -it mariadb mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD"
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT user_login, user_email FROM wp_users;

Getting TLS version and certificate details
openssl s_client -connect khiidenh.42.fr:443

How to reboot:
- sudo reboot
- make up

To change ports:
Ensure that you adjust the change both from server and client side
- To change PHP-FPM port, adjust the port in wordpress-entrypoint and nginx-entrypoint.
- To change MariaDB port, change the port in the config file and in wordpress-entrypoint.
- To change nginx port, change the port in Docker-Compose as well as in nginx-entrypoint.
If port is a privileged port, you need to run the following sudo command:
echo 'net.ipv4.ip_unprivileged_port_start=NEWPORT' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p