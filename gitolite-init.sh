#!/bin/sh
set -e
if [ ! -d "/ssh_keys" ]; then
	mkdir /ssh_keys
	chown redmine:redmine /ssh_keys
    su redmine -s /bin/sh -c "ssh-keygen -N '' -f /ssh_keys/redmine_gitolite_admin_id_rsa" 
    
    echo -e 'Defaults:redmine !requiretty\nredmine ALL=(git) NOPASSWD:ALL' > /etc/sudoers.d/redmine
    chmod 440 /etc/sudoers.d/redmine
    
    su git -c "gitolite setup -pk /ssh_keys/redmine_gitolite_admin_id_rsa.pub"
    su redmine -s /bin/sh -c "mkdir /home/redmine/.ssh"
    su redmine -s /bin/sh -c "ssh-keyscan -H 127.0.0.1 > /home/redmine/.ssh/known_hosts"
    passwd -u git # unlocking user to allow ssh access
    sed -i "s|#[[:space:]]*LOCAL_CODE.*\"\$ENV{HOME}/local\"|LOCAL_CODE\ =>\ \"\$ENV{HOME}/local\"|" /var/lib/git/.gitolite.rc
    sed -i "s|GIT_CONFIG_KEYS.*|GIT_CONFIG_KEYS\ =>\ \'\.\*\',|"  /var/lib/git/.gitolite.rc
    
fi

 
exec "$@"
