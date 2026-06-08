#!/bin/bash

#nginx is a web server, its job is to receive HTTP requests from browser and return responses.
#PHP - WordPress is written in PHP - Programming language that runs on the server.
#Unlike HTML, which is just static text, PHP is code that executes and generates HTML dynamically
#So when you request a page, it's not prewritten but instead PHP code runs, queries db, builds HTML, returns.
#nginx cannot execute PHP files itself. Nginx only serves static files.

#PHP-FPM is a separate process that executes PHP code. FPM stands for FastCGI Process Manager
#Nginx handles HTTP, serves static files.. php-fpm executes PHP code and returns the result to nginx.
#They talk to each other via FastCGI.

#SSL/TLS are the same thing. It's the encryption layer that sits on top of HTTP, turning it into HTTPS.
#Without it data travels as plain readable text. With it, everything is encrypted.
#Browser -> Server "I want to connect"
#Server -> Browser "Here is my certificate"
#Browser: checks if cert is trusted
#Browser -> Server "Ok, here is a session key encrypted with your public key"
#Server: Decrypts the session key with its private key
#Both: Now share a secret session key nobody else knows

set -e

#On the first container run, generate a certificate and configure the server.
if [ ! -e /etc/.firstrun ]; then
#Generate a self-signed certificate for HTTPS. (what does this REALLY mean)
#req -x509. Create a self signed certificate.
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

	#append the nginx configuration to the config file.
	#listen on port 443 (HTTPS) on both IPv4 and IPv6. Http2 enables a protocol which can send multiple requests over one connection.
	#server name: nginx only responds to requests for this domain
	#tells nginx where the certificate and private key are.
	#When a browser connects, nginx shows it the certificate to prove its identity, then uses private k to decrypt.
	#only allow modern versions of TLS.
	#cipher is a specific encryption algorithm.
	#root, serve files from this dir, which is the shared volume where WordPress files live.
	#if the request is a bare directory with no filename, index kicks in and serves index.php
	#try to find $uri as a real file on disk (images), if found, serve it directly, if not fall back to index.php
	#~ [^/]\.php(/|\$) matches any request URL ending in .php.
	#It then forwards it to php-fpm for execution instead of serving as static file.
	#instead of executing PHP itself, nginx passes the request to the WordPress container's php-fpm process listening on port 9000.
	#this is a bridge between nginx and wordpess.
	#tells php-fpm the full path of the PHP file to execute. Without this, php-fpm wouldn't know which file to run.
	#splits the URL into the PHP file part and any extra path info after it.  /index.php/some/path becomes /index.php and /some/path
	#includes a standard set of variables that php fpm needs. things like request method GET/POST.
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
		try_files \$uri /index.php?\$args;
	}

	location ~ [^/]\.php(/|\$) {
	try_files \$fastcgi_script_name =404;

	fastcgi_pass wordpress:9000;
	fastcgi_index index.php;
	fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
	fastcgi_param PATH_INFO \$fastcgi_path_info;
	fastcgi_split_path_info ^(.+\.php)(/.*)\$;
	include fastcgi_params;
	}
}
EOF
	touch /etc/.firstrun
fi
#start the process, daemon off tells nginx to stay in the foreground. If its in background, Docker would think container exited.
exec nginx -g 'daemon off;'
