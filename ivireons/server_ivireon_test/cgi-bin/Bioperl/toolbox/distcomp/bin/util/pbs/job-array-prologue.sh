# For job arrays - calculate MDCE_TASK_ID from PBS_ARRAY_INDEX
MDCE_TASK_ID=${PBS_ARRAY_INDEX}

for x in <SKIP_LIST> ; do
    if [ ${PBS_ARRAY_INDEX} -ge ${x} ]; then
        MDCE_TASK_ID=`expr 1 + ${MDCE_TASK_ID}`
    fi
done
export MDCE_TASK_ID
