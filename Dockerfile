FROM php:7.4-fpm-alpine

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
ENV COMPOSER_VERSION 1.10.6

# docker-entrypoint.sh dependencies
RUN echo "memory_limit=-1" > "$PHP_INI_DIR/conf.d/memory-limit.ini" \
  && echo "date.timezone=${PHP_TIMEZONE:-UTC}" > "$PHP_INI_DIR/conf.d/date_timezone.ini" \
  && apk add --no-cache --virtual .build-deps libjpeg-turbo-dev libpng-dev libzip-dev \
  && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  && docker-php-ext-install gd mysqli opcache tokenizer json zip pdo_mysql \
  &&	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --virtual .polr-phpexts-rundeps $runDeps \
  && apk add --no-cache bash sed git subversion openssh mercurial tini patch \
  && php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');" \
  && php -r "if (hash_file('sha384', '/tmp/composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer --version=${COMPOSER_VERSION} \
  && php -r "unlink('/tmp/composer-setup.php');" \
  && composer --ansi --version --no-interaction \
  && rm -rf /tmp/* /tmp/.htaccess \
  && cd /usr/src \
  && curl -SL https://github.com/cydrobolt/polr/archive/2.2.0.tar.gz  | tar xzC /usr/src \
  && mv polr-2.2.0 polr  \
  && chown -R www-data:www-data /usr/src/polr && cd polr \
  && php /usr/local/bin/composer install --no-dev -o \
  && docker-php-ext-install pdo_mysql


VOLUME /var/www/html

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/local/sbin/php-fpm"]
