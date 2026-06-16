FROM alpine:3.23.4

#installs bash, curl, mariadb-client (to connect to db)
#openssl for cert generation
#php84 runtime
#php-fpm executes PHP code for nginx
#-additional PHP modules that are needed
RUN apk update && apk add bash curl mariadb-client \
        openssl php84 php84-fpm php84-phar php84-json php84-mysqli \
        php84-curl php84-dom php84-fileinfo \
        php84-intl php84-mbstring php84-openssl \
        php84-xml php84-zip php84-iconv php84-simplexml php84-sodium \
        php84-xmlreader php84-zlib php84-tokenizer

#Downloads the WP-CLI (WordPress command line interface() tool from the official source. WP-CLI is a commandline tool
#for managing WordPress installations
RUN cd /usr/local/bin && \
	curl -o wp -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp

COPY ../tools/wordpress-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

ENTRYPOINT [ "wordpress-entrypoint.sh" ]
