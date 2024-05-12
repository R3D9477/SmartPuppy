#!/bin/bash

echo "$(date) Puppy start ping..." >> /puppy/puppy.log
source /puppy/puppy_env.sh

while true ; do
    sleep 43200s
    /puppy/puppy_send_email.sh "Puppy ping at $(date '+%Y-%m-%d %H:%M:%S') ${PUPPY_TIME_ZONE}"
done
