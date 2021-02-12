#!/usr/bin/env bash

set -e # exit on first error
set -u # Treat unset variables as error
set -x # echo

uname -n

pwd # echo path

testname=$1

# Use this script to find quickest-to-start queue when K is backed up
queue=$(./acceptance/k-best-queue.py)

# Get the best queue to submit to
queues="K4-debug K3-debug K3a-debug K2-debug K2a-fun3d"
for queue in $queues; do

    if [[ "$queue" == "K4-"* ]]; then
	nprocs=40
	walltime=50
    elif [[ "$queue" == "K3-"* ]]; then
	nprocs=16
	walltime=50
    elif [[ "$queue" == "K2-"* ]]; then
	nprocs=12
	walltime=50
    elif [[ "$queue" == "K2a-"* ]]; then
	nprocs=12
	walltime=50
    else
	echo "unknown queue requested: $queue"
	exit 1
    fi

    output=`pwd`/../log-${testname}-status.txt

    cat << EOF > ${testname}.pbs
#PBS -S /bin/bash -q ${queue} -l select=1:ncpus=${nprocs}:mpiprocs=${nprocs} -l walltime=00:${walltime}:00
#PBS -N ${testname}
#PBS -o ${testname}
#PBS -W umask=027
#PBS -m n

set -o xtrace   # show commands invoked
set -o errexit  # exit on first error
set -o pipefail # ensure exit with pipe

uname -mrn

cd \$PBS_O_WORKDIR

(./acceptance/${testname}.sh) 2>&1 | tee ${output}

EOF

    printf "Trying K queue: $queue"

    rm -rf ${output}
    (qsub -V -Wblock=true ${testname}.pbs > pbs_id 2>&1) &
    pid=$!

    sleep 20

    job_status=$(qstat `cat pbs_id` | tail -n1 | sed -r 's/\s+/ /g' | cut -d' ' -f8)
    if [[ "${job_status}" == "R" ]]; then
	echo "SUCCESS!"
	break
    else
	echo "FAIL.. try next queue!"
	qdel -Wforce `cat pbs_id`
    fi
done

echo "===================================================================="
echo "     ------>  Running ${testname} on K queue: ${k_queue}"
echo "===================================================================="

# This is where the winning PBS job starts,
# due to the $BUILDLOG file being created
set -x
touch $output
tail -f --pid $pid $output

# Capture test-suite error code, turn of exit-on-error
set +e
wait ${pid}; exit_code=$?

exit ${exit_code}

