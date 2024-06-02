#!/bin/bash
/puppy/puppy_log.sh "[${0}]"
source /puppy/puppy_env.sh

mkdir -p /puppy/SendingQueue
pushd /puppy/SendingQueue

CWN_TO_10s=12

while true ; do

    if [ $(ls -1q . | wc -l) -gt 0 ] ; then

        let CWN_TO_10s=12

        if [ $(ls -1q *.txt | wc -l) -gt 0 ] ; then
            T_FILES=$(ls *.txt)
            /puppy/puppy_send_email.sh "Puppy said something..." "$(cat ${T_FILES})"
            rm ${T_FILES}
        fi

        if [ $(ls -1q *.jpg | wc -l) -gt 0 ] ; then
            S_FILES=$(ls *.jpg)
            /puppy/puppy_log.sh "Puppy send shots ${S_FILES}"
            AI_DESCR=$(python "/puppy/get_openai_description_from_shots.py" ${S_FILES})
            /puppy/puppy_send_email.sh "Puppy saw something (shots)..." "${AI_DESCR}" "-a ${S_FILES}"
            rm ${S_FILES}
        fi

        if [ $(ls -1q *.h264 | wc -l) -gt 0 ] ; then
            V_FILES=$(ls *.h264)
            /puppy/puppy_log.sh "Puppy send videos ${V_FILES}"
            for V_FILE in ${V_FILES} ; do
                AI_DESCR=$(python "/puppy/get_openai_description_from_video.py" ${V_FILE})
                if   [ "${PUPPY_SPEECH_GENERATOR}" == "openai" ]  ; then SPEECH_FILE=$(python "/puppy/get_openai_speech_file.py" ${V_FILE} "${AI_DESCR}")
                elif [ "${PUPPY_SPEECH_GENERATOR}" == "pyttsx3" ] ; then SPEECH_FILE=$(python "/puppy/create_speech_file.py" ${V_FILE} "${AI_DESCR}")
                fi
                if [[ -f "${SPEECH_FILE}" ]] ; then
                    if ffmpeg -i "${V_FILE}" -i "${SPEECH_FILE}" -c copy -map 0 -map -0:a -map 1:a "${V_FILE}.mp4" -y ; then
                        rm ${V_FILE}
                        V_FILE="${V_FILE}.mp4"
                    else
                        /puppy/puppy_log.sh "Puppy cannot apply speech file ${SPEECH_FILE} for ${V_FILE}"
                    fi
                    rm ${SPEECH_FILE}
                else
                    /puppy/puppy_log.sh "Puppy cannot get speech file ${SPEECH_FILE} for ${V_FILE}"
                fi
                /puppy/puppy_send_email.sh "Puppy saw something (video)..." "${AI_DESCR}" "-a ${V_FILE}"
                rm ${V_FILE}
            done
            rm ${V_FILES}
        fi

    fi

    if [ $CWN_TO_10s -gt 0 ] ; then
        let CWN_TO_10s=CWN_TO_10s-1
        if [ $CWN_TO_10s -gt 0 ] ; then
            if /puppy/puppy_is_connected.sh ; then
                /puppy/puppy_log.sh "Puppy OFF radio for powersafe"
                nmcli radio wifi off
            fi
        fi
    fi

    sleep 10s

done

popd
