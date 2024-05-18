#!/bin/bash
/puppy/puppy_log.sh "[${0}]"
source /puppy/puppy_env.sh

while true ; do
    sleep 43200s
    echo "Puppy ping at $(date '+%Y-%m-%d %H:%M:%S') ${PUPPY_TIME_ZONE}" > "/puppy/SendingQueue/$(date '+%Y-%m-%d_%H-%M-%S').txt"
done
