FROM alpine:3.23.4
##Specified version of alpine. It's the base image of Docker container

# #Install nginx, openssl and bash. OpenSSL isfor handling SSL/TLS. Bash for shell scripting..
RUN apk update && \
	apk add nginx openssl bash

# //Copy the executable script, we will execute this later. This command copies from the host machine the executable scrit tools mariadb entrypoint into the containers directory so we can execute it from inside the container.
COPY ../tools/nginx-entrypoint.sh /usr/local/bin

# //make sure its executable
# #create necessary directiores. It is used to store SSL/TLS certificates and keys for secure communications
RUN chmod +x /usr/local/bin/nginx-entrypoint.sh && \
	mkdir -p /etc/nginx/ssl

# //setting up the container environment by choosing file as entrypoint. Entrypoint sets the script to be executed first when the container starts. It does init tasks like setting up the database environment
ENTRYPOINT [ "nginx-entrypoint.sh" ]

