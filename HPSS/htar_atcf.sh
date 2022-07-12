#!/bin/ksh


YYYY=2018
MODEL=$1
TC_name=$2
TC_number=$3

model="`echo $MODEL | tr "[:upper:]" "[:lower:]"`"
basin_letter="`echo $TC_number | tr "[:upper:]" "[:lower:]" | cut -c 2`"
TC_digits="`echo $TC_number | cut -c 3-4`"

#TC_number="`echo ${TC#${TC%????}}`"
echo $MODEL $TC_name $TC_number $model $basin_letter $TC_digits

DATA_DIR="/meso/noscrub/${USER}/MEG/${TC_name}"
mkdir -p $DATA_DIR

RH_DIR="/NCEPPROD/hpssprod/runhistory/2year/rh${YYYY}/${model}/${TC_digits}${basin_letter}"
hsi ls $RH_DIR > list_all_${model}.txt 2>&1

cat list_all_${model}.txt | grep .tar | grep -v .idx >> select_list_all_${model}.txt

#'/NCEPPROD/hpssprod/runhistory/2year/rh'+cycle1[0:4]+'/'+str.lower(model_str) + \
#               '/'+TC_number[2:4]+str.lower(TC_number[1])


YYYY=`echo $CYCLE | cut -c 1-4`


