#!/bin/bash
# Author: L.C. Dawson
#
###################################################
# Script to get download necessary data from HPSS
#
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! # 
#   Make sure you edit the requested walltime     #
#            in the 4 htar scripts                #
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  #
#
###################################################

#==============================================  BEGIN CHANGES  ================================================

export CASE='CA_rain'
export CYCLE=2018112812

export FHR_START=0
export FHR_END=240
export FHR_INC=6

export GET_RAP=false
export CONUS_DOM=true  # set to true if using uszoom (CONUS) or any of 10 CONUS subdomains
export NA_DOM=true     # set to true if using us (N. America), nwatl (West Atlantic), or gom (Gulf of Mexico) domains

export GET_ST4=true
export GET_NOHRSC=true

                     # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! # 
                     #   Make sure you edit the requested walltime     #
                     #            in the 4 htar scripts                #
                     # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #

#===============================================  END CHANGES  =================================================

echo "submitting job to download ${CYCLE} forecast data"
##bsub < htar_fcst.sh
bsub < htar_fcst_hord5.sh
sleep 5
echo "submitting job to download GFS analysis data"
bsub < htar_gfs.sh
sleep 5
echo "submitting job to download RAP analysis data"
#bsub < htar_rap.sh
sleep 5
echo "submitting job to download Stage IV/NOHRSC analysis data"
bsub < htar_pcp.sh

exit


