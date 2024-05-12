#!/bin/bash

echo "$(date) Puppy send email..." >> /puppy/puppy.log
source /puppy/puppy_env.sh

/puppy/puppy_connect.sh

if [[ $(curl -Is "https://www.google.com" | head -n 1) =~ "200" ]] ; then
    rm ~/sent.lock
    echo "${2}" | mutt -s "${1}" ${3} -- ${PUPPY_DST_EMAIL}
else
    echo "$(date) Puppy failed to send email" >> /puppy/puppy.log
fi
