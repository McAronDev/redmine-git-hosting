#!/bin/sh
set -ex

if [ ! -f "/var/lib/git/.gitolite.rc" ]; then

   su git -c "gitolite setup -pk $RSAPATH.pub"
   sed -i "s|#[[:space:]]*LOCAL_CODE.*\"\$ENV{HOME}/local\"|LOCAL_CODE\ =>\ \"\$ENV{HOME}/local\"|" /var/lib/git/.gitolite.rc
   sed -i "s|GIT_CONFIG_KEYS.*|GIT_CONFIG_KEYS\ =>\ \'\.\*\',|"  /var/lib/git/.gitolite.rc

fi
