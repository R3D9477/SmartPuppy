#!/bin/bash

echo "$(date) Puppy connect..." >> /puppy/puppy.log
source /puppy/puppy_env.sh

if [[ $(curl -Is "https://www.google.com" | head -n 1) =~ "200" ]] ; then
    echo "$(date) Puppy already connected..." >> /puppy/puppy.log
    exit 0
fi

if [ "$(nmcli radio wifi)" != "enabled" ] ; then
    nmcli radio wifi on
    sleep 1s
fi

if [ "$(nmcli radio wifi)" != "enabled" ] ; then
    echo "$(date) Puppy try to restart NetworkManager service..." >> /puppy/puppy.log
    service NetworkManager stop
    sleep 3s
    service NetworkManager restart
    sleep 3s
    echo "$(systemctl status NetworkManager)" >> /puppy/puppy.log
    nmcli radio wifi on
    sleep 3s
fi

if [ "$(nmcli radio wifi)" == "enabled" ] ; then
    echo "$(date) Puppy successfully ON nmcli radio wifi" >> /puppy/puppy.log
else
    echo "$(date) Puppy failed to ON nmcli radio wifi" >> /puppy/puppy.log
fi

if ! [[ -z "${PUPPY_WIFI1_SSID}" ]]; then
    if ! [[ -z "${PUPPY_WIFI1_PASS}" ]]; then
        echo "$(date) Puppy try to connect ${PUPPY_WIFI1_SSID} password ${PUPPY_WIFI1_PASS}" >> /puppy/puppy.log
        nmcli device wifi connect "${PUPPY_WIFI1_SSID}" password ${PUPPY_WIFI1_PASS}
    else
        echo "$(date) Puppy try to connect ${PUPPY_WIFI1_SSID}" >> /puppy/puppy.log
        nmcli device wifi connect "${PUPPY_WIFI1_SSID}"
    fi
    sleep 1s
fi

if ! [[ $(curl -Is "https://www.google.com" | head -n 1) =~ "200" ]] ; then
    if ! [[ -z "${PUPPY_WIFI2_SSID}" ]]; then
        if ! [[ -z "${PUPPY_WIFI2_PASS}" ]]; then
            echo "$(date) Puppy try to connect ${PUPPY_WIFI2_SSID} password ${PUPPY_WIFI2_PASS}" >> /puppy/puppy.log
            nmcli device wifi connect "${PUPPY_WIFI2_SSID}" password ${PUPPY_WIFI2_PASS}
        else
            echo "$(date) Puppy try to connect ${PUPPY_WIFI2_SSID}" >> /puppy/puppy.log
            nmcli device wifi connect "${PUPPY_WIFI2_SSID}"
        fi
        sleep 1s
    fi
fi

if [[ $(curl -Is "https://www.google.com" | head -n 1) =~ "200" ]] ; then
    echo "$(date) Puppy successfully connected..." >> /puppy/puppy.log
else
    echo "$(date) Puppy failed to connect..." >> /puppy/puppy.log
fi
