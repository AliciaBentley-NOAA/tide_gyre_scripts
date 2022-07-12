#!/bin/ksh
#BSUB -J fcst_htar
#BSUB -o fcst_htar.out
#BSUB -e fcst_htar.out
#BSUB -n 1
#BSUB -W 02:00
#BSUB -P GFS-T2O
#BSUB -q transfer
#BSUB -R "rusage[mem=1000]"
#BSUB -R "affinity[core]"


#==============================================  BEGIN CHANGES  ================================================

#CASE='Irma'
#CYCLE=2017090812

#FHR_START=0
#FHR_END=96
#FHR_INC=6

#===============================================  END CHANGES  =================================================

#REPO_DIR=/meso/save/Logan.Dawson/EMC_meg/Logan_MEG/FV3retro_scripts
if [ $SITE = GYRE ]; then
#   RETRO_DIR="/gpfs/gp2/ptmp/$USER/FV3_retros/${CASE}"
   RETRO_DIR="/meso/save/Alicia.Bentley/MEG/EC_tracks/${CASE}"
elif [ $SITE = TIDE ]; then
   RETRO_DIR="/gpfs/tp2/ptmp/$USER/FV3_retros/${CASE}"
fi

mkdir -p $RETRO_DIR

cd $RETRO_DIR

/bin/rm -rf htar_fcst_done

YYYY=`echo $CYCLE | cut -c 1-4`
YYYYMM=`echo $CYCLE | cut -c 1-6`
YYYYMMDD=`echo $CYCLE | cut -c 1-8`
HH=`echo $CYCLE | cut -c 9-10`

#========================================  GET FV3GFS FORECASTS  ==============================================
RT_SDATE=2018052518

R1_SDATE=2017112500
R1_EDATE=2018053100

R2a_SDATE=2017052500
R2a_EDATE=2017080200

R2b_SDATE=2017080200
R2b_EDATE=2017110900

R3_SDATE=2016112500
R3_EDATE=2017053100

R4a_SDATE=2016052200
R4a_EDATE=2016081700

R4b_SDATE=2016081700
R4b_EDATE=2016112600

R5_SDATE=2015112500
R5_EDATE=2016053100

R6_SDATE=2015050300
R6_EDATE=2015112800


if ((${CYCLE} >= ${RT_SDATE})) ; then
   FV3_ARCHIVE=/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_C/Q2FY19/prfv3rt1/${CYCLE}/gfsa.tar

elif (((${CYCLE} >= $R1_SDATE) && (${CYCLE} <= $R1_EDATE))) ; then
   FV3_ARCHIVE=/NCEPDEV/emc-global/5year/Fanglin.Yang/WCOSS_DELL_P3/Q2FY19/fv3q2fy19retro1/${CYCLE}/gfsa.tar

elif (((${CYCLE} >= $R2a_SDATE) && (${CYCLE} <= $R2a_EDATE))) ; then
   FV3_ARCHIVE=/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_C/Q2FY19/fv3q2fy19retro2/${CYCLE}/gfsa.tar

elif (((${CYCLE} >= $R2b_SDATE) && (${CYCLE} <= $R2b_EDATE))) ; then
   FV3_ARCHIVE=/NCEPDEV/emc-global/5year/Fanglin.Yang/WCOSS_DELL_P3/Q2FY19/fv3q2fy19retro2/${CYCLE}/gfsa.tar

elif (((${CYCLE} >= $R3_SDATE) && (${CYCLE} <= $R3_EDATE))) ; then
   FV3_ARCHIVE=/NCEPDEV/emc-global/5year/Fanglin.Yang/WCOSS_DELL_P3/Q2FY19/fv3q2fy19retro3/${CYCLE}/gfsa.tar

elif (((${CYCLE} >= $R4a_SDATE) && (${CYCLE} <= $R4a_EDATE))) ; then
   FV3_ARCHIVE=/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_C/Q2FY19/fv3q2fy19retro4/${CYCLE}/gfsa.tar

elif (((${CYCLE} >= $R4b_SDATE) && (${CYCLE} <= $R4b_EDATE))) ; then
   FV3_ARCHIVE=/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_DELL_P3/Q2FY19/fv3q2fy19retro4/${CYCLE}/gfsa.tar

elif (((${CYCLE} >= $R5_SDATE) && (${CYCLE} <= $R5_EDATE))) ; then
   FV3_ARCHIVE=/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_DELL_P3/Q2FY19/fv3q2fy19retro5/${CYCLE}/gfsa.tar

elif (((${CYCLE} >= $R6_SDATE) && (${CYCLE} <= $R6_EDATE))) ; then
   FV3_ARCHIVE=/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_DELL_P3/Q2FY19/fv3q2fy19retro6/${CYCLE}/gfsa.tar

fi


echo "Building list of files to extract"
htar -tvf $FV3_ARCHIVE > list_all.txt
cat list_all.txt | grep gfs.t${HH}z.pgrb2.0p25.f | grep -v .idx >> select_list.txt_tmp
nlines=`wc -l select_list.txt_tmp`
nlines=${nlines% select*}


it=1
ti=0
FHR=$FHR_START
while [ $it -le $nlines ] ; do
   var="`cat select_list.txt_tmp | head -n $it | tail  -1`"
   ff="`echo ${var#${var%???}}`"
   let "TEMPFHR=FHR+1000"
   FHR3="`echo $TEMPFHR | cut -c 2-`"
   if (((${FHR3} == $ff) && (${FHR3} <= $FHR_END))) ; then
      echo "./"${var#* ./} >> select_list_fv3.txt
      let "ti=ti+1"
      let "FHR=FHR+FHR_INC"
   fi
   let "it=it+1"
done

nlines=`wc -l select_list_fv3.txt`
nlines=${nlines% select*}

echo "Extracting "${nlines}" FV3GFS files from "${cycle}" cycle"
htar -xvf $FV3_ARCHIVE -L select_list_fv3.txt

it=1
while [ $it -le $nlines ] ; do
   tempvar="`cat select_list_fv3.txt | head -n $it | tail  -1`"
   var="`echo $tempvar | cut -c 23-`"
   mv ${tempvar} ./fv3gfs.${YYYYMMDD}.${var}.grib2
   let "it=it+1"
done
#==============================================================================================================






#========================================  GET GFS FORECASTS  =================================================
GFS_CHANGE_DATE1=2016051000
GFS_CHANGE_DATE2=2017072000

if ((${CYCLE} < ${GFS_CHANGE_DATE1})) ; then
   GFS_ARCHIVE=/NCEPPROD/hpssprod/runhistory/rh${YYYY}/${YYYYMM}/${YYYYMMDD}/com_gfs_prod_gfs.${CYCLE}.pgrb2_0p25.tar

elif (((${CYCLE} >= ${GFS_CHANGE_DATE1}) && (${CYCLE} <= ${GFS_CHANGE_DATE2}))) ; then
   GFS_ARCHIVE=/NCEPPROD/hpssprod/runhistory/rh${YYYY}/${YYYYMM}/${YYYYMMDD}/com2_gfs_prod_gfs.${CYCLE}.pgrb2_0p25.tar

elif ((${CYCLE} > ${GFS_CHANGE_DATE2})) ; then
   GFS_ARCHIVE=/NCEPPROD/hpssprod/runhistory/rh${YYYY}/${YYYYMM}/${YYYYMMDD}/gpfs_hps_nco_ops_com_gfs_prod_gfs.${CYCLE}.pgrb2_0p25.tar
fi


it=1
while [ $it -le $nlines ] ; do
   tempvar="`cat select_list_fv3.txt | head -n $it | tail  -1`"
   var="`echo $tempvar | cut -c 19-`"
   echo ./${var} >> select_list_gfs.txt
   let "it=it+1"
done

echo "Extracting "${nlines}" GFS files from "${cycle}" cycle"
htar -xvf $GFS_ARCHIVE -L select_list_gfs.txt

it=1
while [ $it -le $nlines ] ; do
   tempvar="`cat select_list_gfs.txt | head -n $it | tail  -1`"
   var="`echo $tempvar | cut -c 7-`"
   mv ${tempvar} gfs.${YYYYMMDD}.${var}.grib2
   let "it=it+1"
done
#==============================================================================================================


/bin/rm -rf select_list_fv3.txt select_list_gfs.txt select_list.txt_tmp list_all.txt
/bin/rm -fR ${RETRO_DIR}/gfs.${YYYYMMDD}/

touch htar_fcst_done



exit
