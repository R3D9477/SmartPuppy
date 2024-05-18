#!/bin/bash

/puppy/puppy_log.sh "-------------------------------------------------------------------------------------------"
/puppy/puppy_log.sh "Puppy Start..."
source /puppy/puppy_env.sh

PUPPY_CONNECT_LOCK=$(realpath ~/.puppy_connect.lock)
rm ${PUPPY_CONNECT_LOCK}

PUPPY_MAIL_LOCK=$(realpath ~/.puppy_mail.lock)
rm ${PUPPY_MAIL_LOCK}

MUTT_LOCK_FILE=$(realpath ~/sent.lock)
rm ${MUTT_LOCK_FILE}

sleep 60s

/puppy/puppy_log.sh "Puppy Welcome..."

/puppy/puppy_connect.sh
timedatectl set-ntp true
timedatectl set-timezone "${PUPPY_TIME_ZONE}"

sleep 1s

/puppy/puppy_send_email.sh "Puppy Welcome" "Puppy Welcome at $(date '+%Y-%m-%d %H:%M:%S') ${PUPPY_TIME_ZONE}"

/puppy/puppy_ping.sh &
/puppy/puppy_send.sh &

mkdir -p /puppy/SendingQueue
mkdir -p /puppy/Videos
pushd /puppy/Videos
rm *.tmp
REC_TO=0
while true ; do
    RPI_GPIO_GET=$(raspi-gpio get ${PUPPY_WOOF_PIN})
    if [[ "${RPI_GPIO_GET}" =~ "level=1" ]] ; then
        if [ ${REC_TO} -eq 0 ] ; then
            /puppy/puppy_send_email.sh "Puppy WOOF WOOF WOOF" "Woof at $(date '+%Y-%m-%d_%H-%M-%S') ${PUPPY_TIME_ZONE}" &
            /puppy/puppy_take_shots.sh
            let REC_TO=PUPPY_VIDEO_COUNT
        fi
    else
        let REC_TO=0
    fi
    if [ ${REC_TO} -gt 0 ] ; then
        let REC_TO=REC_TO-1
        /puppy/puppy_clean.sh
        /puppy/puppy_record_video.sh
    fi
    sleep 1s
done
popd
