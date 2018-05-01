FROM alpine
WORKDIR /root
COPY nginx.conf /etc/nginx/nginx.conf
COPY run.sh /root/run.sh

RUN apk --no-cache --update --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ add \
    make cmake g++ pcre-dev openssl-dev ca-certificates

ADD http://nginx.org/download/nginx-1.13.11.tar.gz /tmp/nginx.tar.gz
RUN mkdir /tmp/nginx && \
    tar xvzf /tmp/nginx.tar.gz -C /tmp/nginx --strip-components=1 && \
    cd /tmp/nginx && \
    ./configure \
        --prefix=/usr \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/lock/nginx.lock \
        --user=www-data \
        --group=www-data \
        --with-http_ssl_module \
        --with-http_v2_module \
        --without-http_uwsgi_module \
        --without-http_scgi_module \
        --without-http_memcached_module \
        --without-http_geo_module \
        --without-mail_pop3_module \
        --without-mail_imap_module \
        --without-mail_smtp_module && \
    make && \
    make install

EXPOSE 8443

STOPSIGNAL SIGTERM

RUN set -x ; \
  addgroup -g 82 -S www-data ; \
  adduser -u 82 -D -S -G www-data www-data && exit 0 ; exit 1

RUN rm -rf /tmp/*

RUN chmod +x /root/run.sh

CMD ["/root/run.sh"]
