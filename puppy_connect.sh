#!/bin/bash
/puppy/puppy_log.sh "[${0}]"
source /puppy/puppy_env.sh

if /puppy/puppy_is_connected.sh ; then
    exit 0
fi

PUPPY_CONNECT_LOCK=$(realpath ~/.puppy_connect.lock)

if [ -f "${PUPPY_CONNECT_LOCK}" ] ; then
    for i in $(seq 1 10) ; do
        sleep 1s
        if /puppy/puppy_is_connected.sh ; then
            exit 0
        elif ! [ -f "${PUPPY_CONNECT_LOCK}" ] ; then
            break
        elif [[ $i -eq 10 ]] ; then
            exit 1
        fi
    done
fi

touch "${PUPPY_CONNECT_LOCK}"
/puppy/puppy_log.sh "Puppy connect [start]"

if [ "$(nmcli radio wifi)" != "enabled" ] ; then
    nmcli -w 5 radio wifi on
    sleep 3s
fi

if [ "$(nmcli radio wifi)" != "enabled" ] ; then
    /puppy/puppy_log.sh "Puppy try to restart NetworkManager service..."
    service NetworkManager stop
    sleep 3s
    service NetworkManager restart
    sleep 3s
    nmcli -w 5 radio wifi on
fi

if [ "$(nmcli radio wifi)" == "enabled" ] ; then /puppy/puppy_log.sh "Puppy successfully ON nmcli radio wifi"
else /puppy/puppy_log.sh "Puppy failed to ON nmcli radio wifi"
fi

for i in $(seq 1 5) ; do

    if ! [[ -z "${PUPPY_WIFI1_SSID}" ]] ; then
        if ! [[ -z "${PUPPY_WIFI1_PASS}" ]] ; then
            if nmcli -w 5 device wifi connect "${PUPPY_WIFI1_SSID}" password ${PUPPY_WIFI1_PASS} ; then
                /puppy/puppy_log.sh "Puppy connected to ${PUPPY_WIFI1_SSID} (private)"
                break
            else
                /puppy/puppy_log.sh "Puppy failed to connect to ${PUPPY_WIFI1_SSID} (private)"
            fi
        else
            if nmcli -w 5 device wifi connect "${PUPPY_WIFI1_SSID}" ; then
                /puppy/puppy_log.sh "Puppy connected to ${PUPPY_WIFI1_SSID} (public)"
                break
            else
                /puppy/puppy_log.sh "Puppy failed to connect to ${PUPPY_WIFI1_SSID} (public)"
            fi
        fi
    fi

    if ! /puppy/puppy_is_connected.sh ; then
        if ! [[ -z "${PUPPY_WIFI2_SSID}" ]] ; then
            if ! [[ -z "${PUPPY_WIFI2_PASS}" ]] ; then
                if nmcli -w 5 device wifi connect "${PUPPY_WIFI2_SSID}" password ${PUPPY_WIFI2_PASS} ; then
                    /puppy/puppy_log.sh "Puppy connected to ${PUPPY_WIFI2_SSID} (private)"
                    break
                else
                    /puppy/puppy_log.sh "Puppy failed to connect to ${PUPPY_WIFI2_SSID} (private)"
                fi
            else
                if nmcli -w 5 device wifi connect "${PUPPY_WIFI2_SSID}" ; then
                    /puppy/puppy_log.sh "Puppy connected to ${PUPPY_WIFI2_SSID} (public)"
                    break
                else
                    /puppy/puppy_log.sh "Puppy failed to connect to ${PUPPY_WIFI2_SSID} (public)"
                fi
            fi
        fi
    fi

    sleep 1s

done

rm "${PUPPY_CONNECT_LOCK}"
/puppy/puppy_log.sh "Puppy connect [end]"

exit $(/puppy/puppy_is_connected.sh)
