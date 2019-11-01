#!/bin/sh
set -ex

export RSAPATH="$(pwd)/plugins/redmine_git_hosting/ssh_keys/redmine_gitolite_admin_id_rsa"

/ssh-init.sh

/gitolite-init.sh


/previous-entrypoint.sh rails --version # any rails command needed to start migrations
su-exec redmine rake redmine:plugins:migrate
su-exec redmine rake redmine_git_hosting:install_gitolite_hooks

exec su-exec redmine "$@"
