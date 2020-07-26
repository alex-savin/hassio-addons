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
	alpine-sdk=1.0-r0 \
	cmake=3.17.2-r0 \
	git \
	rtl-sdr=0.6.0-r0 \
	librtlsdr-dev=0.6.0-r0 \
	libusb-dev=1.0.23-r0 \
#    \
#    && cd /tmp \
#    && git clone git://git.osmocom.org/rtl-sdr.git \
#    && cd rtl-sdr \
#    && mkdir build \
#    && cd build \
#    && cmake ../ -DINSTALL_UDEV_RULES=ON -DDETACH_KERNEL_DRIVER=ON -DCMAKE_INSTALL_PREFIX:PATH=/usr/local \
#    && cmake ../ -DDETACH_KERNEL_DRIVER=ON \
#    && make \
#    && make install \
    \
    && cd /tmp \
    && git clone https://github.com/merbanan/rtl_433 \
    && cd rtl_433/ \
    && git checkout feat-atlas \
    && mkdir build \
    && cd build \
    && cmake ../ \
    && make \
    && make install

FROM smarthouseint/addon-base-amd64:0.0.7

ENV LANG en_US.utf8
ENV TZ America/New_York

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY rootfs /

#COPY --from=build-env /usr/local/lib/pkgconfig /usr/local/lib/pkgconfig
COPY --from=build-env /usr/local/include /usr/local/include
COPY --from=build-env /usr/local/lib /usr/local/lib
COPY --from=build-env /usr/local/bin /usr/local/bin
COPY --from=build-env /usr/local/etc /usr/local/etc


RUN \
    set -o pipefail \
    \
    && echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories \
    && echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
    && echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    \
    && apk --no-cache --update --available upgrade\
    && apk add --no-cache \
	rtl-sdr=0.6.0-r0 \
	librtlsdr-dev=0.6.0-r0 \
	libusb=1.0.23-r0 \
	mosquitto-clients=1.6.9-r0 \
	jq=1.6-r1

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
    io.hass.arch="amd64" \
    io.hass.type="addon" \
    io.hass.version=0.0.1 \
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
