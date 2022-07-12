#!/bin/ksh
#BSUB -J fcst_htar
#BSUB -o fcst_htar.%J.out
#BSUB -e fcst_htar.%J.out
#BSUB -n 1
#BSUB -W 02:00
#BSUB -P GFS-T2O
#BSUB -q transfer
#BSUB -R "rusage[mem=1000]"
#BSUB -R "affinity[core]"


#==============================================  BEGIN CHANGES  ================================================

# /gpfs/gp2/... and /gpfs/tp2/... for Alicia
# /gpfs/gd1/... and /gpfs/td1/... for Geoff
# /gpfs/gd2/... and /gpfs/td2/... for Logan
# /gpfs/gd3/... and /gpfs/td3/... for Tracey

if [ $SITE = GYRE ]; then
#   RETRO_DIR="/gpfs/gp2/ptmp/$USER/FV3_retros/${CASE}"
   RETRO_DIR="/meso/save/Alicia.Bentley/MEG/EC_tracks/${CASE}"
elif [ $SITE = TIDE ]; then
   RETRO_DIR="/gpfs/tp2/ptmp/$USER/FV3_retros/${CASE}"
fi

#===============================================  END CHANGES  =================================================

mkdir -p $RETRO_DIR

cd $RETRO_DIR

/bin/rm -rf htar_fcst_done

YYYY=`echo $CYCLE | cut -c 1-4`
YYYYMM=`echo $CYCLE | cut -c 1-6`
YYYYMMDD=`echo $CYCLE | cut -c 1-8`
HH=`echo $CYCLE | cut -c 9-10`

#========================================  GET FV3GFS FORECASTS  ==============================================
#RT_SDATE=2018052518
#R1c_SDATE=2017112500
#R1c_EDATE=2018053100

####################
## updated from above to draw from HORD5 re-runs for begi
RT_SDATE=2018081518
R1c_SDATE=2017112500
R1c_EDATE=2018081512
####################

R2c_SDATE=2017060100
R2c_EDATE=2017113018

R3_SDATE=2016112500
R3_EDATE=2017053100

R4c_SDATE=2016052700
R4c_EDATE=2016113018

R5_SDATE=2015112500
R5_EDATE=2016053100

R6c_SDATE=2015052800
R6c_EDATE=2015113018


if ((${CYCLE} >= ${RT_SDATE})) ; then
   FV3_ARCHIVE=/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_C/Q2FY19/prfv3rt1/${CYCLE}/gfsa.tar

elif (((${CYCLE} >= $R1c_SDATE) && (${CYCLE} <= $R1c_EDATE))) ; then
   FV3_ARCHIVE=/NCEPDEV/emc-global/5year/Fanglin.Yang/WCOSS_DELL_P3/Q2FY19/fv3q2fy19retro1c/${CYCLE}/gfsa.tar

elif (((${CYCLE} >= $R2c_SDATE) && (${CYCLE} <= $R2c_EDATE))) ; then
   FV3_ARCHIVE=/NCEPDEV/emc-global/5year/Fanglin.Yang/WCOSS_DELL_P3/Q2FY19/fv3q2fy19retro2c/${CYCLE}/gfsa.tar

elif (((${CYCLE} >= $R3_SDATE) && (${CYCLE} <= $R3_EDATE))) ; then
   FV3_ARCHIVE=/NCEPDEV/emc-global/5year/Fanglin.Yang/WCOSS_DELL_P3/Q2FY19/fv3q2fy19retro3/${CYCLE}/gfsa.tar

elif (((${CYCLE} >= $R4c_SDATE) && (${CYCLE} <= $R4c_EDATE))) ; then
   FV3_ARCHIVE=/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_DELL_P3/Q2FY19/fv3q2fy19retro4c/${CYCLE}/gfsa.tar

elif (((${CYCLE} >= $R5_SDATE) && (${CYCLE} <= $R5_EDATE))) ; then
   FV3_ARCHIVE=/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_DELL_P3/Q2FY19/fv3q2fy19retro5/${CYCLE}/gfsa.tar

elif (((${CYCLE} >= $R6c_SDATE) && (${CYCLE} <= $R6c_EDATE))) ; then
   FV3_ARCHIVE=/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_DELL_P3/Q2FY19/fv3q2fy19retro6c/${CYCLE}/gfsa.tar

fi


echo "Building list of files to extract"
htar -tvf $FV3_ARCHIVE > list_all_${CYCLE}.txt
cat list_all_${CYCLE}.txt | grep gfs.t${HH}z.pgrb2.0p25.f | grep -v .idx >> select_list_${CYCLE}.txt_tmp
nlines=`wc -l select_list_${CYCLE}.txt_tmp`
nlines=${nlines% select*}


it=1
ti=0
FHR=$FHR_START
while [ $it -le $nlines ] ; do
   var="`cat select_list_${CYCLE}.txt_tmp | head -n $it | tail  -1`"
   ff="`echo ${var#${var%???}}`"
   let "TEMPFHR=FHR+1000"
   FHR3="`echo $TEMPFHR | cut -c 2-`"
   if (((${FHR3} == $ff) && (${FHR3} <= $FHR_END))) ; then
      echo "./"${var#* ./} >> select_list_fv3_${CYCLE}.txt
      let "ti=ti+1"
      let "FHR=FHR+FHR_INC"
   fi
   let "it=it+1"
done

nlines=`wc -l select_list_fv3_${CYCLE}.txt`
nlines=${nlines% select*}

echo "Extracting "${nlines}" FV3GFS files from "${cycle}" cycle"
htar -xvf $FV3_ARCHIVE -L select_list_fv3_${CYCLE}.txt

it=1
while [ $it -le $nlines ] ; do
   tempvar="`cat select_list_fv3_${CYCLE}.txt | head -n $it | tail  -1`"
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
   tempvar="`cat select_list_fv3_${CYCLE}.txt | head -n $it | tail  -1`"
   var="`echo $tempvar | cut -c 19-`"
   echo ./${var} >> select_list_gfs_${CYCLE}.txt
   let "it=it+1"
done

echo "Extracting "${nlines}" GFS files from "${cycle}" cycle"
cd ${RETRO_DIR}/gfs.${YYYYMMDD}/
htar -xvf $GFS_ARCHIVE -L ${RETRO_DIR}/select_list_gfs_${CYCLE}.txt
cd ${RETRO_DIR}

it=1
while [ $it -le $nlines ] ; do
   tempvar="`cat select_list_gfs_${CYCLE}.txt | head -n $it | tail  -1`"
   var="`echo $tempvar | cut -c 7-`"
   mv ${RETRO_DIR}/gfs.${YYYYMMDD}/${tempvar} ./gfs.${YYYYMMDD}.${var}.grib2
   let "it=it+1"
done
#==============================================================================================================

/bin/rm -rf select_list_fv3_${CYCLE}.txt select_list_gfs_${CYCLE}.txt select_list_${CYCLE}.txt_tmp list_all_${CYCLE}.txt
/bin/rm -fR ${RETRO_DIR}/gfs.${YYYYMMDD}/

touch htar_fcst_done



exit
