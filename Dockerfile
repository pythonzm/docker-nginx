FROM centos:7

MAINTAINER dockerzm

ENV NGINX_VERSION 1.13.1

RUN CONFIG="\
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --user=nginx \
        --group=nginx \
        --with-http_ssl_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-threads \
        --with-file-aio \        
        " \
        && groupadd -r nginx \
        && useradd -s /sbin/nologin -g nginx nginx \
        && yum install -y \
                gcc \
                make \
                openssl \
                openssl-devel \
                pcre \
                pcre-devel \
                zlib \
                zlib-devel \
                curl \
                iproute \
        && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
        && mkdir -p /usr/src \
        && tar -zxC /usr/src -f nginx.tar.gz \
        && rm nginx.tar.gz \
        && cd /usr/src/nginx-$NGINX_VERSION \
        && ./configure $CONFIG --with-debug \
        && make -j$(getconf _NPROCESSORS_ONLN) \
        && mv objs/nginx objs/nginx-debug \
        && ./configure $CONFIG \
        && make -j$(getconf _NPROCESSORS_ONLN) \
        && make install \
        && rm -rf /etc/nginx/html/ \
        && mkdir /etc/nginx/conf.d/ \
        && mkdir -p /usr/share/nginx/html/ \
        && install -m644 html/index.html /usr/share/nginx/html/ \
        && install -m644 html/50x.html /usr/share/nginx/html/ \
        && install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
        && strip /usr/sbin/nginx* \
        && rm -rf /usr/src/nginx-$NGINX_VERSION \
        # forward request and error logs to docker log collector
        && ln -sf /dev/stdout /var/log/nginx/access.log \
        && ln -sf /dev/stderr /var/log/nginx/error.log

COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
