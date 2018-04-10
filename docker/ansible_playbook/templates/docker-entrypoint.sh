#!/bin/bash

#set -e
set -u


# mongodb only uses systemd but using docker,
# process 1 can be /bin/bash, not sysctl, so it would
# just fail, we need to run it manually
sudo -u mongodb /bin/bash -c "/usr/bin/mongod --fork --config /etc/mongod.conf"

# don't setup replication until mongo is ready
netstat -tnlp | grep {{software.common_configurations.mongodb.port}}
ret=$?
while [ "$ret" != "0" ]
do
  echo Waiting for mongo
  sleep 5
  netstat -tnlp | grep {{software.common_configurations.mongodb.port}}
  ret=$?
done

# oplog enabled (not used anymore)
#mongo < /tmp/rsconfig.js 

service elasticsearch start
service nginx start

# don't start hub until ES is ready
netstat -tnlp | grep 9200
ret=$?
while [ "$ret" != "0" ]
do
  echo Waiting for ES
  sleep 5
  netstat -tnlp | grep 9200
  ret=$?
done

# Launch hub in a tmux session
su - biothings -c "
source ~/pyenv/bin/activate
cd biothings.api && git reset --hard && git pull && pip install -r requirements.txt && cd ..
cd {{ app_name }}
git reset --hard && git pull
tmux new-session -d -s hub
tmux send-keys 'python bin/hub.py' C-m
tmux detach -s hub"

if [ "$?" != "0" ]
then
    echo "Unable to start hub"
    exit 255
fi

echo "now run webapp"
# We have TTY, so probably an interactive container...
if test -t 0; then
  echo "probably an interactive container"
    # here
  
  # Some command(s) has been passed to container? Execute them and exit.
  # No commands provided? Run bash.
  if [[ $@ ]]; then 
    eval $@
  else 
    export PS1='[\u@\h : \w]\$ '
    /bin/bash
  fi

# Detached mode
else
  echo "not interactive"
  if [[ $@ ]]; then 
    eval $@
  fi
  # until it dies
  mkdir -p /var/run/sshd # prevent "Missing privilege separation directory" error
  /usr/sbin/sshd -D
fi

