#!/bin/bash
# Author: L.C. Dawson
#
#####################################
# Example driver script for running retro scripts on Tide/Gyre
# Probably most necessary changes:
#   list of CYCLEs
#   list of domains
#   specific scripts to run and specifications like ending forecast hour
#   Walltime: for this example, roughly 80 images were created on 15 min of walltime.
#   Project (BSUB -P setting)? Queue (BSUB -q setting)? 
#####################################


#==============================================  BEGIN CHANGES  ================================================

# /gpfs/gp2/... and /gpfs/tp2/... for Alicia
# /gpfs/gd1/... and /gpfs/td1/... for Geoff
# /gpfs/gd2/... and /gpfs/td2/... for Logan
# /gpfs/gd3/... and /gpfs/td3/... for Tracey

CASE="bomb_cyclone"

if [ $SITE = GYRE ]; then
   RETRO_DIR="/gpfs/gp2/ptmp/$USER/FV3_retros/${CASE}"
elif [ $SITE = TIDE ]; then
   RETRO_DIR="/gpfs/tp2/ptmp/$USER/FV3_retros/${CASE}"
fi
LOCAL_REPO="/meso/save/Alicia.Bentley/FV3_retros"

cd $RETRO_DIR
cp ${LOCAL_REPO}/*.ncl .
cp ${LOCAL_REPO}/convert.sh .



for CYCLE in 2017122700 2017122800 2017122900 2017123000 2017123100 2018010100 2018010200 2018010300 2018010400 2018010500 
do

if [[ $CYCLE = 2018010600 ]]; then
   FHR_END=12
elif [[ $CYCLE = 2018010500 ]]; then
   FHR_END=36
elif [[ $CYCLE = 2018010400 ]]; then
   FHR_END=60
elif [[ $CYCLE = 2018010300 ]]; then
   FHR_END=84
elif [[ $CYCLE = 2018010200 ]]; then
   FHR_END=108
elif [[ $CYCLE = 2018010100 ]]; then
   FHR_END=132
elif [[ $CYCLE = 2017123100 ]]; then
   FHR_END=156
elif [[ $CYCLE = 2017123000 ]]; then
   FHR_END=180
elif [[ $CYCLE = 2017122900 ]]; then
   FHR_END=204
elif [[ $CYCLE = 2017122800 ]]; then
   FHR_END=228
elif [[ $CYCLE = 2017122700 ]]; then
   FHR_END=240
elif [[ $CYCLE = 2018090700 ]]; then
   FHR_END=240

else
   FHR_END=24
fi


for domain in us
do

YYYYMMDD=$(echo $CYCLE | cut -b1-8)
HH=$(echo $CYCLE | cut -b10-11)

if [[ $domain = "new" ]]; then

regionname="atl"
minlat=12
maxlat=50
minlon=-80
maxlon=-35

echo "submitting ${domain} domain script for ${CYCLE}"

cat > $RETRO_DIR/runfv3_${regionname}_${CYCLE}.sh <<EOF
#!/bin/bash
#
#BSUB -J ${regionname}_${CYCLE}
#BSUB -o ${regionname}_${CYCLE}.out
#BSUB -e ${regionname}_${CYCLE}.err
#BSUB -n 2
#BSUB -R span[ptile=1]
#BSUB -W 02:00
#BSUB -P GFS-T2O
#BSUB -q "dev2"
#BSUB -R "affinity[core]"
#BSUB -x
#BSUB -a poe


source ~/.bashrc

cd $RETRO_DIR

 ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'regionname="${regionname}"' 'minlat="${minlat}"' 'maxlat="${maxlat}"' 'minlon="${minlon}"' 'maxlon="${maxlon}"' 'fhr_end="${FHR_END}"' plot_fv3lambertslp.ncl &
 ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'regionname="${regionname}"' 'minlat="${minlat}"' 'maxlat="${maxlat}"' 'minlon="${minlon}"' 'maxlon="${maxlon}"' 'fhr_end="${FHR_END}"' plot_fv3lambert10mwind.ncl &
 ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'regionname="${regionname}"' 'minlat="${minlat}"' 'maxlat="${maxlat}"' 'minlon="${minlon}"' 'maxlon="${maxlon}"' 'fhr_end="${FHR_END}"' plot_fv3lambert500.ncl &
 ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'regionname="${regionname}"' 'minlat="${minlat}"' 'maxlat="${maxlat}"' 'minlon="${minlon}"' 'maxlon="${maxlon}"' 'fhr_end="${FHR_END}"' plot_fv3lambert6hprecip.ncl &
 ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'regionname="${regionname}"' 'minlat="${minlat}"' 'maxlat="${maxlat}"' 'minlon="${minlon}"' 'maxlon="${maxlon}"' 'fhr_end="${FHR_END}"' plot_fv3lambert24hprecip.ncl &
 ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'regionname="${regionname}"' 'minlat="${minlat}"' 'maxlat="${maxlat}"' 'minlon="${minlon}"' 'maxlon="${maxlon}"' 'fhr_end="${FHR_END}"' 'accum_range="120"' plot_fv3lamberttotalprecip.ncl &

exit

EOF


bsub < $RETRO_DIR/runfv3_${regionname}_${CYCLE}.sh
sleep 5


else

echo "submitting ${domain} domain script for ${CYCLE}"

cat > $RETRO_DIR/runfv3_${domain}_${CYCLE}.sh <<EOF
#!/bin/bash
#
#BSUB -J ${domain}_${CYCLE}
#BSUB -o ${domain}_${CYCLE}.out
#BSUB -e ${domain}_${CYCLE}.err
#BSUB -n 10
#BSUB -R span[ptile=1]
#BSUB -W 04:00
#BSUB -P GFS-T2O
#BSUB -q "dev2"
#BSUB -R "affinity[core]"
#BSUB -x
#BSUB -a poe


source ~/.bashrc

cd $RETRO_DIR

ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'fhr_end="${FHR_END}"' plot_fv3lambertslp.ncl &
#ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'fhr_end="${FHR_END}"' plot_fv3lambert10mwind.ncl &
#ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'fhr_end="${FHR_END}"' plot_fv3lambertgust.ncl &
#ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'fhr_end="${FHR_END}"' plot_fv3lambert850wind.ncl &
#ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'fhr_end="${FHR_END}"' plot_fv3lambertpw.ncl &
ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'fhr_end="${FHR_END}"' plot_fv3lambert500.ncl &
#ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'fhr_end="${FHR_END}"' plot_fv3lambert250wind.ncl &
#ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'fhr_end="${FHR_END}"' plot_fv3lambertptype.ncl &
#ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'fhr_end="${FHR_END}"' plot_fv3lambert24hprecip.ncl &
#ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'fhr_end="${FHR_END}"' plot_fv3lamberttotalprecip.ncl &
#ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'fhr_end="${FHR_END}"' 'snow_type="snod"' plot_fv3lambert24hsnow.ncl &
#ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'fhr_end="${FHR_END}"' 'snow_type="snod"' plot_fv3lamberttotalsnow.ncl &
#ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'fhr_end="${FHR_END}"' 'snow_type="weasd"' plot_fv3lambert24hsnow.ncl &
#ncl 'scriptyyyymmddhh="${CYCLE}"' 'scriptregion="${domain}"' 'fhr_end="${FHR_END}"' 'snow_type="weasd"' plot_fv3lamberttotalsnow.ncl &

exit

EOF

bsub < $RETRO_DIR/runfv3_${domain}_${CYCLE}.sh
sleep 5

fi




done
done

exit


