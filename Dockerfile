FROM jpetazzo/dind
MAINTAINER Estevão Mascarenhas, ntxdev <estevao@ntxdev.com.br>

ENV RUBY_MAJOR 2.2
ENV RUBY_VERSION 2.2.1
ENV RUBY_DOWNLOAD_SHA256 5a4de38068eca8919cb087d338c0c2e3d72c9382c804fb27ab746e6c7819ab28

RUN apt-get update && \
    apt-get upgrade -y
RUN apt-get install -y lxc-docker

RUN curl -s -L https://github.com/docker/compose/releases/latest | \
    egrep -o '/docker/compose/releases/download/[0-9.]*/docker-compose-Linux-x86_64' | \
    wget --base=http://github.com/ -i - -O /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    /usr/local/bin/docker-compose --version

RUN apt-get update \
    && apt-get install -y bison libgdbm-dev ruby libgeos-dev ruby-geos git-core nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /usr/src/ruby \
    && curl -fSL -o ruby.tar.gz "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" \
    && echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.gz" | sha256sum -c - \
    && tar -xzf ruby.tar.gz -C /usr/src/ruby --strip-components=1 \
    && rm ruby.tar.gz \
    && cd /usr/src/ruby \
    && autoconf \
    && ./configure --disable-install-doc \
    && make -j"$(nproc)" \
    && make install \
    && apt-get purge -y --auto-remove bison libgdbm-dev ruby \
    && rm -r /usr/src/ruby \

    # Setup Rubygems
    && cd /tmp \
    && echo 'gem: --no-document' > /etc/gemrc \
    && gem install bundler && gem update --system

RUN rm -rf /var/lib/apt/lists/* && \
    truncate -s 0 /var/log/*log && \
    cd /usr/share && rm -fr doc/* man/* info/* lintian/* && \
    mkdir man/man1

RUN cd /usr/lib && ln -s libgeos-3.4.2.so libgeos.so

ENV LOG=file
ENTRYPOINT ["wrapdocker"]
CMD []
