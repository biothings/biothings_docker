#!/bin/bash

if [ ! -f /data/biothings/biothings_studio/bin/ssh_host_key ]; then
    ssh-keygen -f /data/biothings/biothings_studio/bin/ssh_host_key
fi

exec python /data/biothings/biothings_studio/bin/hub.py
