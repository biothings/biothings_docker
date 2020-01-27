#!/bin/bash


echo ARG $@
# manuall stora arg before "set -u"
# if no arg is passed, $1 is unbound and raise
# an error after "set -u"
arg1="$1"

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

# start Cerebro
start-stop-daemon --start -c elasticsearch -b --exec /usr/local/cerebro/bin/cerebro
netstat -tnlp | grep 9000

ret=$?
while [ "$ret" != "0" ]
do
  echo Waiting for cerebro
  sleep 5
  netstat -tnlp | grep 9000
  ret=$?
done

# Launch hub in a tmux session
if [ "X$arg1" = "Xno-update" ]
then
    echo "Skipping biothings.api and biothings_studio self-update"
else
    su - biothings -c "./bin/update_biothings || exit 255"
    if [ "$?" != "0" ]
    then
        echo "Fatal error updating biothings SDK"
        exit 255
    fi
    su - biothings -c "./bin/update_studio || exit 255"
    if [ "$?" != "0" ]
    then
        echo "Fatal error updating Studio"
        exit 255
    fi
fi

if [ "X{{ api_name | default('') }}" = "X" ]
then
     # pristine studio
    su - biothings -c "./bin/run_studio"
else
    if [ "X$arg1" = "Xno-update" ]
    then
        echo "Skipping {{ api_name | default('') }} self-update"
    else
        su - biothings -c "./bin/update_api && ./bin/run_api"
    fi
fi

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
  # until it dies
  mkdir -p /var/run/sshd # prevent "Missing privilege separation directory" error
  /usr/sbin/sshd -D
fi

