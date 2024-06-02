#!/bin/bash
/puppy/puppy_log.sh "[${0}]"
source /puppy/puppy_env.sh

if [ ${PUPPY_VIDEO_DURATION_MS} -gt 0 ] ; then
    VF_NAME="$(date '+%Y-%m-%d_%H-%M-%S').h264"
    /puppy/puppy_log.sh "Puppy get video ${VF_NAME}"
    libcamera-vid -o ${VF_NAME} -t ${PUPPY_VIDEO_DURATION_MS} --nopreview --rotation ${PUPPY_CAMERA_ROTATION}
    cp ${VF_NAME} "/puppy/SendingQueue/"
fi
