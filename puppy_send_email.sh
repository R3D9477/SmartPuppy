#!/bin/bash
/puppy/puppy_log.sh "[${0}]"
source /puppy/puppy_env.sh

PUPPY_MAIL_LOCK=$(realpath ~/.puppy_mail.lock)

if [ -f "${PUPPY_MAIL_LOCK}" ] ; then
    for i in $(seq 1 10) ; do
        sleep 1s
        if ! [ -f "${PUPPY_MAIL_LOCK}" ] ; then
            break
        elif [[ $i -eq 10 ]] ; then
            /puppy/puppy_log.sh "Puppy failed to send email ${1} [blocked]"
            exit 1
        fi
    done
fi

touch "${PUPPY_MAIL_LOCK}"
/puppy/puppy_log.sh "Puppy send email ${1} to ${PUPPY_DST_EMAIL}"

if /puppy/puppy_connect.sh ; then

    MUTT_LOCK_FILE=$(realpath ~/sent.lock)

    if [ -f ${MUTT_LOCK_FILE} ] ; then

        for i in $(seq 1 5) ; do
            sleep 1s
            if ! [ -f ${MUTT_LOCK_FILE} ] ; then
                break
            fi
        done

        if [ -f ${MUTT_LOCK_FILE} ] ; then
            rm ${MUTT_LOCK_FILE}
        fi
    fi

    echo "${2}" | mutt -s "${1}" ${3} -- ${PUPPY_DST_EMAIL}

    /puppy/puppy_log.sh "Puppy successfully sent email ${1}, files: ${3}"
    rm "${PUPPY_MAIL_LOCK}"
    exit 0

fi

/puppy/puppy_log.sh "Puppy failed to send email ${1}, files: ${3}"
rm "${PUPPY_MAIL_LOCK}"
exit 1
