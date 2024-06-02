#!/bin/bash
/puppy/puppy_log.sh "[${0}]"
source /puppy/puppy_env.sh

WF_NAME="$(date '+%Y-%m-%d_%H-%M-%S')"

for i in $(seq 1 ${PUPPY_SHOTS_COUNT}); do
    SHOT_FILE_NAME="${WF_NAME}_${i}.jpg"
    /puppy/puppy_log.sh "Puppy get shot ${SHOT_FILE_NAME}"
    libcamera-still -o "${SHOT_FILE_NAME}" --width 640 --height 480 --nopreview --rotation ${PUPPY_CAMERA_ROTATION}
    sleep 0.5s
done

for i in $(seq 1 ${PUPPY_SHOTS_COUNT}); do
    cp "${WF_NAME}_${i}.jpg" "/puppy/SendingQueue/"
done
