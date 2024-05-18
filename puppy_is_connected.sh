#!/bin/bash
source /puppy/puppy_env.sh

#if ! [ -z "$(nmcli device wifi | grep '*')" ] ; then
if [[ $(curl -Is "https://www.google.com" | head -n 1) =~ "200" ]] ; then
    exit 0
fi
#fi

exit 1
