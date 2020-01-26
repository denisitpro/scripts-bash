#!/bin/bash

useradd -m username
mkdir /home/username/.ssh
echo 'ssh-rsa public key ' > /home/username/.ssh/authorized_keys
chmod 600 /home/username/.ssh/authorized_keys
chmod 700 /home/username/.ssh/
chown -R username:username /home/username/.ssh/
echo "username ALL=(ALL) ALL" >> /etc/sudoers.d/username
chmod 0440 /etc/sudoers.d/username
usermod -s /bin/bash username
passwd username