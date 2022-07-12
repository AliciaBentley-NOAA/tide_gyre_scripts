#!/bin/ksh
#BSUB -J pcp_htar
#BSUB -o pcp_htar.out
#BSUB -e pcp_htar.out
#BSUB -n 1
#BSUB -W 01:15
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

#GET_ST4=true
#GET_NOHRSC=false

#===============================================  END CHANGES  =================================================

REPO_DIR=/meso/save/Logan.Dawson/EMC_meg/Logan_MEG/FV3retro_scripts
if [ $SITE = GYRE ]; then
   RETRO_DIR="/gpfs/gp2/ptmp/$USER/FV3_retros/${CASE}"
elif [ $SITE = TIDE ]; then
   RETRO_DIR="/gpfs/tp2/ptmp/$USER/FV3_retros/${CASE}"
fi

mkdir -p $RETRO_DIR

cd $RETRO_DIR

/bin/rm -rf htar_pcp_done

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

##### Stage IV
   if $GET_ST4; then
      ST4_CHANGE_DATE=2017042700

      if ((${VALID} >= ${ST4_CHANGE_DATE})) ; then
         ST4_ARCHIVE=/NCEPPROD/hpssprod/runhistory/rh${YYYY}/${YYYYMM}/${YYYYMMDD}/com2_pcpanl_prod_pcpanl.${YYYYMMDD}.tar
      else
         ST4_ARCHIVE=/NCEPPROD/hpssprod/runhistory/rh${YYYY}/${YYYYMM}/${YYYYMMDD}/com_hourly_prod_nam_pcpn_anal.${YYYYMMDD}.tar
      fi

      if [[ -e ${RETRO_DIR}/ST4.${VALID}.06h.grb ]] ; then
         echo ${VALID}" Stage IV analysis exists"
      else
         echo "Extracting "${VALID}" Stage IV analysis"
         htar -xvf $ST4_ARCHIVE ./ST4.${VALID}.06h.gz
         gunzip ST4.${VALID}.06h.gz
         mv ./ST4.${VALID}.06h ./ST4.${VALID}.06h.grb
      fi
   fi # end of GET_ST4 logical statement

##### NOHRSC
   if $GET_NOHRSC; then
      if [[ -e ${RETRO_DIR}/sfav2_CONUS_6h_${VALID}_grid184.grb2 ]] ; then
         echo ${VALID}" NOHRSC analysis exists"
      else
         echo "Downloading "${VALID}" NOHRSC analysis"
         wget --tries=2 http://www.nohrsc.noaa.gov/snowfall_v2/data/${YYYYMM}/sfav2_CONUS_6h_${VALID}_grid184.grb2
      fi
   fi # end of GET_NOHRSC logical statement


done <"$file"
#==============================================================================================================


touch htar_pcp_done



exit
