FROM alpine:3.19.2
# //Specified version of alpine. It's the base image of Docker container

#//RUN command updates the Alpine package index and installs MariaDB and mariadb client tools
RUN apk update && \
	apk add mariadb mariadb-client bash

# //Copy the executable script and the server config, we will execute this later. This command copies from the host machine the executable scrit tools mariadb entrypoint into the containers directory so we can execute it from inside the container.
COPY ../tools/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
COPY ../tools/mariadb-entrypoint.sh /usr/local/bin

#//make sure its executable
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

# //setting up the container environment by choosing file as entrypoint. Entrypoint sets the script to be executed first when the container starts. It does init tasks like setting up the database environment
ENTRYPOINT [ "mariadb-entrypoint.sh" ]

