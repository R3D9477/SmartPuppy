#!/bin/bash

echo "$(date) Puppy Start..." > /puppy/puppy.log
source /puppy/puppy_env.sh

sleep 60s

echo "$(date) Puppy Welcome..." >> /puppy/puppy.log

/puppy/puppy_connect.sh
timedatectl set-ntp true
timedatectl set-timezone "${PUPPY_TIME_ZONE}"

/puppy/puppy_send_email.sh "Puppy Welcome" "Puppy Welcome at $(date '+%Y-%m-%d %H:%M:%S') ${PUPPY_TIME_ZONE}"

sleep 3s

echo "$(date) Puppy start ping and send..." >> /puppy/puppy.log

/puppy/puppy_ping.sh &
/puppy/puppy_send.sh &

echo "$(date) Puppy start clean and record..." >> /puppy/puppy.log

/puppy/puppy_clean.sh
/puppy/puppy_record.sh
