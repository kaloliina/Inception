#!/bin/bash

#nginx is a web server, its job is to receive HTTP requests from browser and return responses.
#it cannot execute PHP itself, instead it forwards PHP requests to php-fpm.
#php-fpm executes WordPress PHP code and returns HTML to nginx. They talk to each other with FastCGI.
#SSL/TLS encrypts the connection between browser and server (HTTP/HTTPS)
#certificates proves server identity and contains the public key for encryption. It works like a handshake process.

set -e

#On the first container run, generate a certificate and configure the server.
if [ ! -e /etc/.firstrun ]; then
#Generate a self-signed certificate.
#req -x509. Create a self signed certificate. (Not by a trusted authority!)
#days is how long it's valid.
#-newkey rsa:2048, generate a new public/private key pair using RSA algo, 2048 bits long.
#-nodes means don't password protect the private key so nginx can start without additional input.
#-out.cert.crt saves the certificate here.
#-keyout cert.key saves the private key here (never leaves the server, used for decryption)
#-subj skip questions, just set the domain name
 openssl req -x509 -days 365 -newkey rsa:2048 -nodes\
	-out '/etc/nginx/ssl/cert.crt' \
	-keyout '/etc/nginx/ssl/cert.key' \
	-subj "/CN=$DOMAIN_NAME" \
	>/dev/null 2>/dev/null

	#append nginx server config to config file.
	#listen on port 443.
	#$DOMAIN_NAME says only respond to requests for this domain.
	#ceriticate: shown to browsers to prove identity
	#private key: used to decrypt incoming session key.
	#secure TLS versions (others are outdated)
	#use strong encryption algorithms only.

	#serve files from shared volume where WP lives.
	#for bare directory requests, serve index.php (https://khiidenh.42.fr/)
	#for all requests:
	#1. try to find as real file (images etc) -> serve directly
	#2. try as directory -> find index.php inside it (/wp-admin example turns into wp-admin/index.php)
	#3. nothing found -> hand to WordPress via index.php?args=about
	#for requests ending in .php
	#nginx cannot execute PHP so forward to php-fpm in wp container
	#fastcgi params are variables that php-fpm needs
	#return 404 if php file not found
	#send to php-fpm (wordpress container)
	#tell which file to execute
	cat << EOF >> /etc/nginx/http.d/default.conf
server {
	listen 443 ssl http2;
	listen [::]:443 ssl http2;
	server_name $DOMAIN_NAME;

	ssl_certificate /etc/nginx/ssl/cert.crt;
	ssl_certificate_key /etc/nginx/ssl/cert.key;
	ssl_protocols TLSv1.2 TLSv1.3;
	ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;

	root /var/www/html;
	index index.php;

	location / {
		try_files \$uri \$uri/ /index.php?\$args;
	}

	location ~ \.php$ {
	include fastcgi_params;
	try_files \$fastcgi_script_name =404;
	fastcgi_pass wordpress:9000;
	fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
	}
}
EOF
	touch /etc/.firstrun
fi
#start the process, daemon off tells nginx to stay in the foreground. If its in background, Docker would think container exited.
exec nginx -g 'daemon off;'
