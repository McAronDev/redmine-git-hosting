#!/bin/sh
set -ex 
/ssh-init.sh
/usr/sbin/sshd
/gitolite-init.sh
/previous-entrypoint.sh "$@"


exec "$@"
