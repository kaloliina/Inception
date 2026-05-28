from alpine:3.19.2

#installs bash, curl (to transfer data from or to a server), mariadb client to interact with db
#icu-data-full international components for Unicode data handling internationalization
#ghostscript and imamagic tools for processing and converting image formats
#openssl a toolkit for SSL/TLS and general cryptography
#php82 . Provide PHP version 8.2 and its various modules, essential for running WordPress and interacting with dbs, files
RUN apk update && apk add bash curl mariadb-client icu-data-full ghostscript \
        imagemagick openssl php82 php82-fpm php82-phar php82-json php82-mysqli \
        php82-curl php82-dom php82-exif php82-fileinfo php82-pecl-igbinary \
        php82-pecl-imagick php82-intl php82-mbstring php82-openssl \
        php82-xml php82-zip php82-iconv php82-shmop php82-simplexml php82-sodium \
        php82-xmlreader php82-zlib php82-tokenizer

#Downloads the WP-CLI (WordPress command line interface() tool from the official source. WP-CLI is a commandline tool
#for managing WordPress installations
RUN cd /usr/local/bin && \
	curl -o wp -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp

COPY ../tools/wordpress-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

ENTRYPOINT [ "wordpress-entrypoint.sh" ]
