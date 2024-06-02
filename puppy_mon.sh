#!/bin/bash
/puppy/puppy_log.sh "[${0}]"
source /puppy/puppy_env.sh

CPU_t=$((($(cat /sys/class/thermal/thermal_zone0/temp))/1000))
/puppy/puppy_log.sh "Puppy current CPU temperature: $(CPU_t) tC"

CPU_p=$(top -b -d1 -n1|grep -i "Cpu(s)"|head -c21|cut -d ' ' -f3|cut -d '%' -f1)
/puppy/puppy_log.sh "Puppy current CPU usage: $(CPU_p) %"

CPU_proc=$(ps aux | sort -nrk 3,3 | head -n 10)
/puppy/puppy_log.sh "Puppy top 10 processes: ${CPU_proc}"

while true ; do
    CPU_t=$((($(cat /sys/class/thermal/thermal_zone0/temp))/1000))
    if [ ${CPU_t} -gt 80 ] ; then
        /puppy/puppy_log.sh "Puppy CPU temperature: ${CPU_t} tC"
        if [ ${CPU_t} -gt 90 ] ; then
            /puppy/puppy_log.sh "Puppy overheated with ${CPU_t} tC ! To be reloaded at $(date '+%Y-%m-%d %H:%M:%S') ${PUPPY_TIME_ZONE}"
            /puppy/puppy_send_email.sh "Puppy overheated!" "Puppy overheated with ${CPU_t} tC ! To be reloaded at $(date '+%Y-%m-%d %H:%M:%S') ${PUPPY_TIME_ZONE}"
            sleep 5s
            shutdown -r now
        fi
    fi
    CPU_p=$(top -b -d1 -n1|grep -i "Cpu(s)"|head -c21|cut -d ' ' -f3|cut -d '%' -f1)
    if [ ${CPU_p} -gt 75 ] ; then
        /puppy/puppy_log.sh "Puppy CPU usage: ${CPU_p} %"
        CPU_proc=$(ps aux | sort -nrk 3,3 | head -n 10)
        /puppy/puppy_log.sh "Puppy top 10 processes: ${CPU_proc}"
    fi
    sleep 10s
done
