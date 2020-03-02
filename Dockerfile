FROM alpine:3.10
LABEL maintainer="Chris Kankiewicz <Chris@ChrisKankiewicz.com>"

# Define Variable Mumble
ARG adress_mumble_server=$adress_mumble_server
ARG port_mumble_server=$port_mumble_server
ARG password_mumble_server=$password_mumble_server
ARG name_mumble_server=$name_mumble_server
ENV adress_mumble_server=${adress_mumble_server}
ENV port_mumble_server=${port_mumble_server}
ENV password_mumble_server=${password_mumble_server}
ENV name_mumble_server=${name_mumble_server}

# Define Mumble version
ARG MUMBLE_VERSION=1.3.0

# Create Mumble directories
RUN mkdir -pv /opt/mumble /etc/mumble

# Create non-root user
RUN adduser -DHs /sbin/nologin mumble

# Copy config file
COPY files/config.ini /etc/mumble/config.ini
RUN sed -i "s/CHANGE_PORT/${port_mumble_server}/g" /etc/mumble/config.ini
RUN sed -i "s/CHANGE_PASSWORD/${password_mumble_server}/g" /etc/mumble/config.ini
RUN sed -i "s/CHANGE_NAME/${name_mumble_server}/g" /etc/mumble/config.ini

# Copy SuperUser password update script
COPY files/supw /usr/local/bin/supw
RUN chmod +x /usr/local/bin/supw

# Set the bzip archive URL
ARG BZIP_URL=https://github.com/mumble-voip/mumble/releases/download/${MUMBLE_VERSION}/murmur-static_x86-${MUMBLE_VERSION}.tar.bz2

# Install dependencies, fetch Mumble bzip archive and chown files
RUN apk add --update ca-certificates bzip2 tar tzdata wget \
    && wget -qO- ${BZIP_URL} | tar -xjv --strip-components=1 -C /opt/mumble \
    && apk del ca-certificates bzip2 tar wget && rm -rf /var/cache/apk/* \
    && chown -R mumble:mumble /etc/mumble /opt/mumble

# Expose ports
EXPOSE ${port_mumble_server} ${port_mumble_server}/udp

# Set running user
USER mumble

# Set volumes
VOLUME /etc/mumble

# Default command
CMD ["/opt/mumble/murmur.x86", "-fg", "-ini", "/etc/mumble/config.ini"]
