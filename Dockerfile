FROM redmine:4-alpine

RUN set -ex \
    && apk add --no-cache --virtual .build-deps cmake libgpg-error-dev libssh2-dev gcc make musl-dev \
    && apk add --no-cache gitolite libssh2 openssh-server sudo \
    && cd /usr/src/redmine/plugins \
    && git clone -b v2-stable git://github.com/alphanodes/additionals.git \
    && rm -rf additionals/.git \
    \
    && git clone -b devel https://github.com/jbox-web/redmine_git_hosting.git \
    && rm -rf redmine_git_hosting/.git \
    && cd .. \
    && chown -R redmine:redmine plugins \
    && su -s /bin/sh redmine -c "bundle install --without development test" \
    && apk del .build-deps

ENV REDMINE_PLUGINS_MIGRATE true     

COPY ["ssh-init.sh", "gitolite-init.sh", "entrypoint.sh", "/"]     

RUN set -ex \
    && chmod +x /ssh-init.sh /gitolite-init.sh /entrypoint.sh \
    && mv /docker-entrypoint.sh /previous-entrypoint.sh \
    && mv /entrypoint.sh /docker-entrypoint.sh \
    && rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key 
        
EXPOSE 22


