User Documentation:

This stack contains three services:
- mariadb
    - a database that stores all the data regarding the project: users, posts, comments.
- wordpress
    - wordpress website files and PHP-FPM process that executes PHP code and serves pages to nginx.
- nginx
    - a web server that serves the Wordpress website to the user.

How to start

Git clone the project and navigate to the root of the project.
- MAKE
    - Builds docker images, creates volumes and network, starts all containers.
- MAKE FCLEAN
    - stops and removes everything including data
- MAKE UP
    - uses built images to run the service again.
- MAKE DOWN
    - stops the containers but keeps the data

How to access
- https://khiidenh.42.fr to access the website.
- https://khiidenh.42.fr/wp-login.php to access login page
- https://khiidenh.42.fr/wp-admin to access administration panel

Credentials
- Credentials are located in .env file which is not included in the repository. Move .env file under the srcs folder before
running the project.

Checking services
- docker ps : shows running containers and exposed ports
- docker logs <container> : shows logs for specific container