#!/bin/bash
# ==============================================================================
# Name: submit_run_generate_oi_sst_pbs_chain.sh
# Description: Submit run_generate_oi_sst.pbs for days in order from start_date to end_date.
# Author: Momoe Yoshida
# Usage example: submit_run_generate_oi_sst_pbs_chain.sh 20250111 20250331
# ==============================================================================
start_date="$1"
end_date="$2"

if [ -z "$start_date" ] || [ -z "$end_date" ]; then
    echo "Usage: $0 YYYYMMDD YYYYMMDD"
    exit 1
fi

start_sec=$(date -d "$start_date" +%s)
end_sec=$(date -d "$end_date" +%s)

current_sec=$start_sec
prev_job=""

LOGDIR="/gpfs01/v2/Q9157/momoe/geo_polar_blended_sst/Linux_JCUHPC/blended_home/Logs"

while [ "$current_sec" -le "$end_sec" ]; do

    tar_date=$(date -d "@$current_sec" +%Y%m%d)

YEAR=$(date -d "$tar_date" +%Y)
    DOY=$(date -d "$tar_date" +%j)

    logfile="${LOGDIR}/generate_oi_sst_${YEAR}_${DOY}.log"

    echo "Submitting $tar_date (YEAR=$YEAR DOY=$DOY)"

    if [ -z "$prev_job" ]; then

        jobid=$(qsub \
            -v tar_date=$tar_date,YEAR=$YEAR,DOY=$DOY \
            -o $logfile \
            -N generate_sst${YEAR}_${DOY} \
            run_generate_oi_sst.pbs)

    else
        # job dependency (afterok): each day waits for the previous day
        jobid=$(qsub \
            -W depend=afterok:$prev_job \
            -v tar_date=$tar_date,YEAR=$YEAR,DOY=$DOY \
            -o $logfile \
            -N generate_sst${YEAR}_${DOY} \
            run_generate_oi_sst.pbs)

    fi

    prev_job=$jobid

    current_sec=$((current_sec + 86400))

done
