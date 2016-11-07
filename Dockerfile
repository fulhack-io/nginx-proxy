FROM fulhack/rpi-alpine-nginx:1.11.5
MAINTAINER Jason Wilder <mail@jasonwilder.com>
MAINTAINER klippo <klippo@deny.se>

# Install dependencies
RUN echo "http://nl.alpinelinux.org/alpine/v3.4/community/" >> /etc/apk/repositories
RUN apk add --no-cache ca-certificates bash\
 && update-ca-certificates

# Configure Nginx and apply fix for very long server names
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
 && sed -i 's/^http {/&\n    server_names_hash_bucket_size 128;/g' /etc/nginx/nginx.conf

COPY go-wrapper /usr/local/bin/

# Install Forego
ADD forego.tar /opt/
ENV GOPATH /opt/go
ENV PATH $PATH:$GOPATH/bin

ENV DOCKER_GEN_VERSION 0.7.3

RUN apk add --no-cache wget \
 &&  wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz \
 && tar -C /usr/local/bin -xvzf docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz \
 && rm /docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz \
 && apk del wget 

COPY . /app/
WORKDIR /app/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs"]

CMD ["forego", "start", "-r"]
