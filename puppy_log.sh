#!/bin/bash

PUPPY_LOG_FILE="/puppy/puppy.log"

if [ -f "${PUPPY_LOG_FILE}" ] ; then
if [[ $(stat -c%s "${PUPPY_LOG_FILE}") -gt 10000000 ]] ; then
    rm "${PUPPY_LOG_FILE}"
fi
fi

echo "$(date) ${1}" >> "${PUPPY_LOG_FILE}"
sync "${PUPPY_LOG_FILE}"
