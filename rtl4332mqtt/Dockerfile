ARG BUILD_FROM=smarthouseint/addon-base-amd64:0.0.7
# hadolint ignore=DL3006
FROM ${BUILD_FROM} AS build-env

#SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
    set -o pipefail \
    \
    && echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories \
    && echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
    && echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    \
    && apk update \
    && apk add --no-cache --virtual .build-dependencies \
	alpine-sdk \
	cmake \
	git \
#	libacl=2.2.53-r0 \
#	libbz2=1.0.8-r1 \
#	expat=2.2.9-r1 \
#	lz4-libs=1.9.2-r0 \
#	xz-libs=5.2.5-r0 \
#	libarchive=3.4.3-r0 \
#	ca-certificates=20191127-r0 \
#	nghttp2-libs=1.40.0-r0 \
#	libcurl=7.67.0-r0 \
#	ncurses-terminfo-base=6.1_p20191130-r0 \
#	ncurses-terminfo=6.1_p20191130-r0 \
#	ncurses-libs=6.1_p20191130-r0 \
#	libgcc=9.2.0-r3 \
#	rhash=1.3.9-r0 \
#	libstdc++=9.2.0-r3 \
#	libuv=1.34.0-r0 \
#	cmake=3.15.5-r0 \
#	binutils=2.33.1-r0 \
#	gmp=6.1.2-r1 \
#	isl=0.18-r0 \
#	libgomp=9.2.0-r3 \
#	libatomic=9.2.0-r3 \
#	mpfr4=4.0.2-r1 \
#	mpc1=1.1.0-r1 \
#	gcc=9.3.0-r2 \
#	pcre2=10.35-r0 \
#	git=2.26.2-r0 \
	libusb-dev=1.0.23-r0 \
#	pkgconf=1.7.2-r0 \
#	libusb-dev=1.0.23-r0 \
#	make=4.3-r0 \
#	musl-dev=1.1.24-r9 \
#	go=1.13.14-r0 \
    \
    && cd /home \
    && git clone git://git.osmocom.org/rtl-sdr.git \
    && cd rtl-sdr \
    && mkdir build \
    && cd build \
    && cmake ../ -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON -DCMAKE_INSTALL_PREFIX:PATH=/usr/local \
    && cmake ../ -DDETACH_KERNEL_DRIVER=ON \
    && make \
    && make install \
    \
    && git clone https://github.com/merbanan/rtl_433 \
    && cd rtl_433/ \
    && mkdir build \
    && cd build \
    && cmake ../ \
    && make \
    && make install \
    \
    && apk add --no-cache libusb mosquitto-clients jq


FROM smarthouseint/addon-base-amd64:0.0.7

ENV LANG en_US.utf8
ENV TZ America/New_York

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY rootfs /

#COPY --from=build-env /usr/local/lib/pkgconfig /usr/local/lib/pkgconfig
COPY --from=build-env /usr/local/include /usr/local/include
COPY --from=build-env /usr/local/lib /usr/local/lib
COPY --from=build-env /usr/local/bin /usr/local/bin

RUN \
    set -o pipefail \
    \
    && echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories \
    && echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
    && echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    \
    && apk --no-cache --update --available upgrade\
    && apk add --no-cache \
	libusb=1.0.23-r0 \
	mosquitto-clients \
	jq

#	python3=3.8.1-r0 \
#    && pip3 install \
#	paho-mqtt \
#	pyyaml \
#	pyjson

ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

LABEL \
    io.hass.name="RTL433 TO MQTT" \
    io.hass.description="An RTL433 To MQTT Bridge" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Alex Savin <alex@smarthouse.site>" \
    org.label-schema.description="An RTL433 To MQTT Bridge" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="RTL433 TO MQTT" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://github.com/alex-savin/hassio-addons/tree/master/rtl4332mqtt" \
    org.label-schema.usage="https://github.com/alex-savin/hassio-addons/rtl4332mqtt/tree/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://github.com/alex-savin/hassio-addons/tree/master/rtl4332mqtt" \
    org.label-schema.vendor="SmartHouse's Hass.io Add-ons"
