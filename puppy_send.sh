#!/bin/bash

echo "$(date) Puppy start send..." >> /puppy/puppy.log
source /puppy/puppy_env.sh

mkdir -p /puppy/SendingQueue
pushd /puppy/SendingQueue
CWN_TO=0
while true ; do
    if [ $(ls -1q . | wc -l) -gt 0 ] ; then
        /puppy/puppy_connect.sh
        let CWN_TO=30
        if [[ $(curl -Is "https://www.google.com" | head -n 1) =~ "200" ]] ; then

            W_FILES=$(ls *.jpg)
            AI_DESCR=$(python "/puppy/get_openai_description_from_shots.py" ${W_FILES})

            /puppy/puppy_send_email.sh "Puppy saw something..." "${AI_DESCR}" "-a ${W_FILES}"

            rm ${W_FILES}

            for V_FILE in $(ls *.h264) ; do
                AI_DESCR=$(python "/puppy/get_openai_description_from_video.py" ${W_FILES})
                if   [ "${PUPPY_SPEECH_GENERATOR}" == "openai" ]  ; then SPEECH_FILE=$(python "/puppy/get_openai_speech_file.py" ${V_FILE} "${AI_DESCR}")
                elif [ "${PUPPY_SPEECH_GENERATOR}" == "pyttsx3" ] ; then SPEECH_FILE=$(python "/puppy/create_speech_file.py" ${V_FILE} "${AI_DESCR}")
                fi
                if [[ -f "${SPEECH_FILE}" ]] ; then
                    if ffmpeg -i "${V_FILE}" -i "${SPEECH_FILE}" -c copy -map 0 -map -0:a -map 1:a "${V_FILE}.mp4" -y ; then
                        rm ${V_FILE}
                        rm ${SPEECH_FILE}
                        V_FILE="${V_FILE}.mp4"
                    fi
                fi

                /puppy/puppy_send_email.sh "Puppy saw something..." "${AI_DESCR}" "-a ${V_FILE}"

                rm ${V_FILE}
            done

        fi
    fi
    if [[ $(curl -Is "https://www.google.com" | head -n 1) =~ "200" ]] ; then
        if [ $CWN_TO -gt 0 ] ; then
            let CWN_TO=CWN_TO-1
        else
            nmcli radio wifi off
        fi
    fi
    sleep 10s
done
popd
