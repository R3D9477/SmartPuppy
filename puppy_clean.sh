#!/bin/bash

echo "$(date) Puppy start clean..." >> /puppy/puppy.log
source /puppy/puppy_env.sh

mkdir -p /puppy/Videos
pushd /puppy/Videos
set V_SIZE=$(du -sh --block-size=1M . | awk '{print $1}')
if [[ "$V_SIZE" > ${PUPPY_VIDEO_STORAGE_MAX_SIZE_MB} ]] ; then
    rm $(ls *.h264 | head -1)
fi
popd
