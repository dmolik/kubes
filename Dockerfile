FROM alpine:latest

RUN apk update \
	&& apk upgrade \
	&& apk add json-c libressl ipset iptables libnl3 libnfnetlink libevent \
		iproute2 gmp unbound-libs libldap ldns libcurl \
	&& apk add --no-cache --virtual .build-dependencies \
		gcc make musl-dev curl-dev curl json-c-dev libressl-dev linux-headers libtool \
		autoconf automake ipset-dev iptables-dev libnl3-dev libnfnetlink-dev \
		pkgconf libevent-dev flex bison gettext-dev gmp-dev file openldap-dev \
		unbound-dev  ldns-dev \
	&& mkdir /root/strongswan && cd /root/strongswan \
	&& curl https://download.strongswan.org/strongswan-5.7.1.tar.gz | tar xz --strip-components=1 -C . \
	&& autoreconf -i -f \
	\
	&& ./configure --prefix=/usr --sysconfdir=/etc --enable-connmark --enable-ha --enable-counters \
		 --enable-swanctl --enable-ipsec2 --enable-gmp --enable-curl --enable-unbound --enable-ldap \
		 --enable-socket-dynamic \
		 --enable-sha3 --enable-aesni --enable-gcm \
		 --enable-openssl \
		 --enable-eap-identity \
		 --enable-eap-mschapv2 \
		 --enable-eap-radius \
		 --enable-eap-tls \
		 --enable-xauth-eap \
		 --enable-eap-dynamic \
	\
	&& make -j4 \
	&& make DESTDIR=/root/strongswan-release install \
	&& find   /root/strongswan-release -path \*bin\* -type f -not -path \*sbin/ipsec | xargs strip \
	&& find   /root/strongswan-release -name \*.so\* | xargs strip \
	&& apk del .build-dependencies \
	&& rm -rf /root/strongswan-release/usr/share \
	&& rm -rf /root/strongswan-release/usr/man \
	&& rm -rf /root/strongswan-release/usr/doc \
	&& rm -rf /root/strongswan-release/usr/lib/ipsec/*.la \
	&& rm -rf /root/strongswan-release/usr/lib/ipsec/plugins/*.la \
	&& cp -R /root/strongswan-release/* / \
	&& rm -rf /var/cache/apk/* \
	&& rm -rf /root/strongswan && rm -rf /root/strongswan-release

# vi:syntax=dockerfile
