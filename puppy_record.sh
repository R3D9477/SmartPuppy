#!/bin/bash

echo "$(date) Puppy start record..." >> /puppy/puppy.log
source /puppy/puppy_env.sh

mkdir -p /puppy/SendingQueue
mkdir -p /puppy/Videos
pushd /puppy/Videos
rm *.tmp
REC_TO=0
while true ; do
    if [[ "$(raspi-gpio get ${PUPPY_WOOF_PIN})" == *"level=1"* ]] ; then
        if [ ${REC_TO} -eq 0 ] ; then
            echo "Puppy woof at $(date '+%Y-%m-%d_%H-%M-%S')" >> /puppy/puppy.log
            /puppy/puppy_send_email.sh "Puppy WOOF WOOF WOOF" "Woof at $(date '+%Y-%m-%d_%H-%M-%S') ${PUPPY_TIME_ZONE}"
            REC_TO=${PUPPY_VIDEO_COUNT}
            WF_NAME="$(date '+%Y-%m-%d_%H-%M-%S').woof"
            for i in $(seq 1 ${PUPPY_SHOTS_COUNT}); do libcamera-still -o "${WF_NAME}_${i}.jpg" --width 640 --height 480 --nopreview
            done
            for i in $(seq 1 ${PUPPY_SHOTS_COUNT}); do cp "${WF_NAME}_${i}.jpg" "/puppy/SendingQueue/"
            done
        fi
    else
        let REC_TO=0
        sleep 1s
    fi
    if [ ${REC_TO} -gt 0 ] ; then
        let REC_TO=REC_TO-1
        if [ ${PUPPY_VIDEO_DURATION_MS} -gt 0 ] ; then
            /puppy/puppy_clean.sh
            VF_NAME="$(date '+%Y-%m-%d_%H-%M-%S').h264"
            libcamera-vid -o ${VF_NAME} -t ${PUPPY_VIDEO_DURATION_MS} --nopreview
            cp ${VF_NAME} "/puppy/SendingQueue/"
            /puppy/puppy_clean.sh
        fi
    fi
done
popd
