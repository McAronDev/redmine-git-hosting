FROM redmine:4-alpine

EXPOSE 22

COPY ["ssh-init.sh", "gitolite-init.sh", "entrypoint.sh", "/"]

RUN set -ex \
    && chmod +x /ssh-init.sh /gitolite-init.sh /entrypoint.sh \
    && mv /docker-entrypoint.sh /previous-entrypoint.sh \
    && mv /entrypoint.sh /docker-entrypoint.sh \
    && rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

RUN set -ex \
    && apk add --virtual .build-deps cmake libgpg-error-dev libssh2-dev gcc make musl-dev \
    && apk add gitolite libssh2 openssh-server sudo \
    && rm -rf /var/cache/apk/* \
    && cd /usr/src/redmine/plugins \
    && su-exec redmine git clone -b v2-stable git://github.com/alphanodes/additionals.git \
    && rm -rf additionals/.git \
    \
    && su-exec redmine git clone -b devel https://github.com/jbox-web/redmine_git_hosting.git \
    && rm -rf redmine_git_hosting/.git \
    && cd .. \
    && su-exec redmine bundle install --without development test \
    && apk del .build-deps \
    \
    && echo -e 'Defaults:redmine !requiretty\nredmine ALL=(git) NOPASSWD:ALL' > /etc/sudoers.d/redmine \
    && chmod 440 /etc/sudoers.d/redmine \
    \
    && su-exec redmine mkdir /home/redmine/.ssh \
    && ln -s /usr/local/bin/ruby /usr/bin/ruby


ARG BUILD_FOR=sqlite

# preinstall dependencies
RUN set -ex \
    && adapter=$(echo mysql:mysql2,sqlite:sqlite3,postgresql:postgresql,sqlserver:sqlserver | sed -n "s|.*$BUILD_FOR:\([^,]*\).*|\1|p") \
    && if [ ! "$adapter" ] ; then echo "BUILD_FOR is wrong" 1>&2 && exit 1 ; fi \
    && su-exec redmine cp Gemfile.lock.$adapter Gemfile.lock \
    && su-exec redmine bundle check || bundle install --without development test \
    && su-exec redmine cp -f Gemfile.lock Gemfile.lock.$adapter
       # last line needed because gitolite hooks can not find ruby

        



