#!/bin/sh
set -ex
if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
	# generate fresh rsa key
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa -C '##redmine##'
fi
if [ ! -f "/etc/ssh/ssh_host_dsa_key" ]; then
	# generate fresh dsa key
	ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa -C '##redmine##'
fi

#prepare run dir
if [ ! -d "/var/run/sshd" ]; then
  mkdir -p /var/run/sshd
fi

if [ ! -f "$RSAPATH" ]; then
	su-exec redmine ssh-keygen -N '' -f $RSAPATH
fi

/usr/sbin/sshd
su-exec redmine ssh-keyscan -H 127.0.0.1 > /home/redmine/.ssh/known_hosts

