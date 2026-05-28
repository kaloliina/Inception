#!/bin/bash
set -e

#On the first container run, generate a certificate and configure the server
if [ ! -e /etc/.firstrun ]; then
 #generate certificate for HTTPS
 openssl req -x509 -days 365 -newkey rsa:2048 -nodes\
	-out '/etc/nginx/ssl/cert.crt' \
	-keyout '/etc/nginx/ssl/cert.key' \
	-subj "/CN=$DOMAIN_NAME" \
	>/dev/null 2>/dev/null

	#Configure nginx to serve static wordpress files and to pass PHP requts
	#to the WordPress  container's php-fpm process
	cat << EOF >> /etc/nginx/http.d/default.conf
server {
	listen 443 ssl http2;
	listen [::]:443 ssl http2;
	server_name $DOMAIN_NAME;

	ssl_certificate /etc/nginx/ssl/cert.crt;
	ssl_certificate_key /etc/nginx/ssl/cert.key;

}

