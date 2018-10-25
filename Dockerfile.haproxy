FROM alpine:latest

RUN apk update \
	&& apk upgrade \
	&& apk add pcre2 openssl \
	&& apk add --no-cache --virtual .build-dependencies \
		gcc make musl-dev curl pcre2-dev openssl-dev \
		linux-headers \
	&& mkdir /root/haproxy && cd /root/haproxy \
	&& curl http://www.haproxy.org/download/1.8/src/haproxy-1.8.14.tar.gz -L | tar xz --strip-components=1 -C . \
	&& make PREFIX=/usr -j4 'CFLAGS=-O2 -pipe -fno-strict-aliasing' 'LDFLAGS=-Wl,-O1 -Wl,--as-needed'  TARGET=linux2628 USE_GETADDRINFO=1 USE_TFO=1 USE_THREAD=1 USE_LIBCRYPT=1 USE_NS=1 USE_PCRE2=1 USE_PCRE_JIT2=1 USE_OPENSSL=1  USE_ZLIB=1 \
	&& make DESTDIR=/root/haproxy-release PREFIX=/usr install \
	&& rm -rf /root/haproxy-release/usr/share && rm -rf /root/haproxy-release/usr/doc \
	&& strip /root/haproxy-release/usr/sbin/haproxy \
	&& cp -Rv /root/haproxy-release/* / \
	&& apk del .build-dependencies \
	&& cd / && rm -rf /root/haproxy && rm -rf /root/haproxy-release
