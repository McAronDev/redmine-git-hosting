#!/bin/sh
set -ex
if [ ! -d "/ssh_keys" ]; then
    export REDMINE_PLUGINS_MIGRATE=1
fi

/ssh-init.sh
/usr/sbin/sshd
/gitolite-init.sh
/previous-entrypoint.sh "$@"


exec "$@"
