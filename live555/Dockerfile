ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
RUN \
    apk add --no-cache --virtual .build-dependencies \
	live-media-dev \
	git \
	g++ \
	make \
    \
    && apk add --no-cache \
	live-media-utils \
    \
    && cd /tmp \
    && git clone https://github.com/rgaufman/live555.git \
    && cd live555 \
    \
    && sed -i -e 's/proxyStream\-\%d/stream%02d/g' ./proxyServer/live555ProxyServer.cpp \
    && sed -i -e "s/proxyStream/stream/g" ./proxyServer/live555ProxyServer.cpp \
    \
    && ./genMakefiles linux \
    && make -j4 \
    \
    && cp proxyServer/live555ProxyServer /usr/local/bin/ \
    \
    && rm -rf /tmp/* \
    && apk del --purge .build-dependencies

# Copy data
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]

# Build arugments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="Live555 RTSP Proxy Server" \
    io.hass.description="Live555 RTSP Proxy Server, helps to do not overload cameras by multiple stream clients" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Alex Savin <alex@smarthouse.site>" \
    org.label-schema.description="Live555 RTSP Proxy Server, helps to do not overload cameras by multiple streams" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="Live555 RTSP Proxy Server" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://github.com/alex-savin/hassio-addons/tree/master/live555" \
    org.label-schema.usage="https://github.com/alex-savin/hassio-addons/live555/tree/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://github.com/alex-savin/hassio-addons/tree/master/live555" \
    org.label-schema.vendor="SmartHouse's Hass.io Add-ons"
