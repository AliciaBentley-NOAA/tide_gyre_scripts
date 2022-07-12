#!/bin/ksh
#BSUB -J gfs_htar
#BSUB -o gfs_htar.out
#BSUB -e gfs_htar.out
#BSUB -n 1
#BSUB -W 04:00
#BSUB -P GFS-T2O
#BSUB -q transfer
#BSUB -R "rusage[mem=1000]"
#BSUB -R "affinity[core]"

module use -a /u/Benjamin.Blake/modulefiles
module load anaconda2/latest


#==============================================  BEGIN CHANGES  ================================================

#CASE='Irma'
#CYCLE=2017090900

#FHR_START=0
#FHR_END=84
#FHR_INC=6

#===============================================  END CHANGES  =================================================

REPO_DIR=/meso/save/Logan.Dawson/EMC_meg/Logan_MEG/FV3retro_scripts

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

mkdir -p $RETRO_DIR

cd $RETRO_DIR

/bin/rm -rf htar_gfsanl_done

YYYY=`echo $CYCLE | cut -c 1-4`
YYYYMM=`echo $CYCLE | cut -c 1-6`
YYYYMMDD=`echo $CYCLE | cut -c 1-8`
HH=`echo $CYCLE | cut -c 9-10`

file="${CYCLE}_valids.txt"
if [[ -e ${RETRO_DIR}/${file} ]] ; then
   echo ""
else
   python ${REPO_DIR}/valids.py $CYCLE $FHR_START $FHR_END $FHR_INC
fi

#===============================================  GET ANALYSES  =================================================
GFS_CHANGE_DATE1=2016051000
GFS_CHANGE_DATE2=2017072000

while IFS= read -r line ; do
   VALID="`echo $line`"
   YYYY=`echo $VALID | cut -c 1-4`
   YYYYMM=`echo $VALID | cut -c 1-6`
   YYYYMMDD=`echo $VALID | cut -c 1-8`
   HH=`echo $VALID | cut -c 9-10`

##### GFS
   if ((${VALID} < ${GFS_CHANGE_DATE1})) ; then
      GFS_ARCHIVE=/NCEPPROD/hpssprod/runhistory/rh${YYYY}/${YYYYMM}/${YYYYMMDD}/com_gfs_prod_gfs.${VALID}.pgrb2_0p25.tar

   elif (((${VALID} >= ${GFS_CHANGE_DATE1}) && (${VALID} <= ${GFS_CHANGE_DATE2}))) ; then
      GFS_ARCHIVE=/NCEPPROD/hpssprod/runhistory/rh${YYYY}/${YYYYMM}/${YYYYMMDD}/com2_gfs_prod_gfs.${VALID}.pgrb2_0p25.tar

   elif ((${VALID} > ${GFS_CHANGE_DATE2})) ; then
      GFS_ARCHIVE=/NCEPPROD/hpssprod/runhistory/rh${YYYY}/${YYYYMM}/${YYYYMMDD}/gpfs_hps_nco_ops_com_gfs_prod_gfs.${VALID}.pgrb2_0p25.tar
   fi


   if [[ -e ${RETRO_DIR}/gfs.${YYYYMMDD}.t${HH}z.pgrb2.0p25.f000.grib2 ]] ; then
      echo ${VALID}" GFS analysis exists"
   else
      echo "Extracting "${VALID}" GFS analysis"
      htar -xvf $GFS_ARCHIVE ./gfs.t${HH}z.pgrb2.0p25.f000 
      mv ./gfs.t${HH}z.pgrb2.0p25.f000 ./gfs.${YYYYMMDD}.t${HH}z.pgrb2.0p25.f000.grib2
   fi

done <"$file"
#==============================================================================================================


touch htar_gfsanl_done



exit
