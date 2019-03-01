ARG BUILD_FROM
FROM ${BUILD_FROM}

# Add env
ENV LANG C.UTF-8

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copy root filesystem
COPY rootfs /

# Setup base
RUN \
    apt-get update -y -q \
    && apt-get install -y --no-install-recommends \
	python3 \
	python3-dev \
	python3-pip \
	python3-six \
	python3-pyasn1 \
	python3-setuptools \
    \
    && pip3 install --upgrade \
	six \
	wheel \
    \
    && pip3 install --upgrade \
	google-assistant-library \
	google-auth \
	requests_oauthlib \
	cherrypy \
	flask \
	flask-jsonpify \
	flask-restful \
	grpcio \
	google-assistant-grpc \
	google-auth-oauthlib \
    \
    && apt-get remove -y --purge \
	python3-pip \
	python3-dev \
    \
    && apt-get clean -y \
    \
    && rm -fr \
        /tmp/* \
        /var/{cache,log}/* \
        /var/lib/apt/lists/*

# Build arugments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="Google Assistant Webserver" \
    io.hass.description="An Google Assistant Webserver" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Alex Savin <alex@smarthouse.site>" \
    org.label-schema.description="An Google Assistant Web Server" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="Google Assistant Web Server" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://github.com/alex-savin/hassio-addons/tree/master/google-assistant-webserver" \
    org.label-schema.usage="https://github.com/alex-savin/hassio-addons/google-assistant-webserver/tree/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://github.com/alex-savin/hassio-addons/tree/master/google-assistant-webserver" \
    org.label-schema.vendor="SmartHouse's Hass.io Add-ons"
