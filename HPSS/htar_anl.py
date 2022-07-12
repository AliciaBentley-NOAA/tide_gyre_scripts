#!/usr/bin/env python
# Author: L Dawson
#
# Script to pull analyses from HPSS, rename, and save in desired data directory
# Desired initial cycle and analysis string can be passed in from command line
# If no arguments are passed in, script will prompt user for these inputs
#
# Script History Log:
# 2018-01    L Dawson  initial versioning to pull analyses. Required command line inputs
# 2018-04-24 L Dawson  enhanced functionality by raising exceptions and adding user input prompts
# 2018-05-17 L Dawson  changed data directory declaration to be more independent

import numpy as np
import datetime, time, os, sys, subprocess


# Create data directory (if not already created)
DIR = os.getcwd() 
DATA_DIR = os.path.join(DIR, 'data')
if not os.path.exists(DATA_DIR):
   os.makedirs(DATA_DIR)
os.chdir(DATA_DIR)


# Determine initial date/time
try:
   cycle = str(sys.argv[1])
except IndexError:
   cycle = None

if cycle is None:
   cycle = raw_input('Enter initial analysis time (YYYYMMDDHH): ')
   
yyyy = int(cycle[0:4])
mm   = int(cycle[4:6])
dd   = int(cycle[6:8])
hh   = int(cycle[8:10])

date_str = datetime.datetime(yyyy,mm,dd,hh,0,0)


# Determine desired analysis 
try:
   anl_str = str(sys.argv[2])
except IndexError:
   anl_str = None

if anl_str is None:
   print 'Analysis string options: GFS, FV3, NAM, NAMNEST, RAP, HRRR, RTMA, URMA, REFD, ST4'
   anl_str = raw_input('Enter desired analysis: ')


# Set prefix for correct runhistory path
RH_PRE = '/NCEPPROD/hpssprod/runhistory/'


# Set correct tarball and file prefixes/suffixes

# RTMA/URMA
if str.upper(anl_str) == 'RTMA' or str.upper(anl_str) == 'URMA':
   if str.upper(anl_str) == 'RTMA':
      TAR_PREFIX  = 'com2_rtma_prod_rtma2p5.'
      FILE_PREFIX = 'rtma2p5.t'
   elif str.upper(anl_str) == 'URMA':
      TAR_PREFIX  = 'com2_urma_prod_urma2p5.'
      FILE_PREFIX = 'urma2p5.t'
   TAR_SUFFIX  = '.tar'        # updated to full correct one later
   FILE_SUFFIX = 'z.2dvaranl_ndfd.grb2'

# Stage-IV analysis
elif str.upper(anl_str) == 'ST4':
   TAR_PREFIX  = 'com2_pcpanl_prod_pcpanl.'
   TAR_SUFFIX  = '.tar'
   FILE_PREFIX = 'ST4.'

   st4_accum = raw_input('Enter 1, 6, or 24 for desired accumulation length: ')
   if int(st4_accum) == 1:
      FILE_SUFFIX   = '.01h.gz'
   elif st4_accum == '6':
      FILE_SUFFIX   = '.06h.gz'
   elif st4_accum == '24':
      FILE_SUFFIX   = '.24h.gz'
   else:
      raise ValueError, 'Must enter 1, 6, or 24 for desired accumulation'

# MRMS 3-D reflectivity mosaics
elif str.upper(anl_str) == 'RADAR' or str.upper(anl_str) == "REFD":
   TAR_PREFIX  = 'com_hourly_prod_radar.'
   TAR_SUFFIX  = '.save.tar'
   FILE_PREFIX = 'refd3d.t'
   FILE_SUFFIX = 'z.grb2f00'

# GFS analysis
elif str.upper(anl_str) == 'GFS':

   gfs_changedate1 = datetime.datetime(2016,05,10,00,0,0)
   gfs_changedate2 = datetime.datetime(2017,07,20,00,0,0)

   if date_str < gfs_changedate1:
      TAR_PREFIX = "com_gfs_prod_gfs."
   elif (date_str >= gfs_changedate1) and (date_str <= gfs_changedate2):
      TAR_PREFIX = "com2_gfs_prod_gfs."
   elif date_str > gfs_changedate2:
      TAR_PREFIX = "gpfs_hps_nco_ops_com_gfs_prod_gfs."

   TAR_SUFFIX   = '.pgrb2_0p25.tar'

   ## File prefixes correctly set later

# FV3 analysis
elif str.upper(anl_str) == 'FV3':
   TAR_FILE = 'gfs.tar'

   ## File prefixes correctly set later

# EC analysis
elif str.upper(anl_str) == 'EC':
   TAR_PREFIX  = 'ecm'
   TAR_SUFFIX  = '.tar'

   ## File prefixes correctly set later

# NAM analysis
elif str.upper(anl_str) == 'NAM':
   TAR_PREFIX   = 'com2_nam_prod_nam.'

   nam_resolution = raw_input('Enter 12 or 32 for desired file resolution: ')
   if nam_resolution == '12':
      TAR_SUFFIX   = '.awip.tar'
   elif nam_resolution == '32':
      TAR_SUFFIX   = '.awip32.tar'
   else:
      raise ValueError, 'Must enter 12 or 32 for desired resolution'

   ##File prefixes correctly set later

# NAM Nest analysis
elif str.upper(anl_str) == 'NAM3' or str.upper(anl_str) == 'NAMNEST':
   TAR_PREFIX   = 'com2_nam_prod_nam.'
   TAR_SUFFIX   = '.conusnest.tar'

# RAP/HRRR analyses
elif str.upper(anl_str) == 'RAP' or str.upper(anl_str) == 'HRRR':
   if str.upper(anl_str) == 'RAP':
      TAR_PREFIX  = 'com2_rap_prod_rap.'
      FILE_PREFIX = 'rap.t'
   #  TAR_SUFFIX  = '.wrf.tar'        # updated to full correct one later
   #  FILE_SUFFIX = 'z.wrfprsf00.grib2'
      TAR_SUFFIX  = '.awp130.tar'        # updated to full correct one later
      FILE_SUFFIX = 'z.awp130pgrbf00.grib2'
   elif str.upper(anl_str) == 'HRRR':
      TAR_PREFIX  = 'com2_hrrr_prod_hrrr.'
      FILE_PREFIX = 'hrrr.t'
      TAR_SUFFIX  = '.wrf.tar'        # updated to full correct one later
      FILE_SUFFIX = 'z.wrfprsf00.grib2'


# By default, will ask for command line input to determine which analysis files to pull 
# User can uncomment and modify the next line to bypass the command line calls
#nhrs = np.arange(0,7,6)

try:
   nhrs
except NameError:
   nhrs = None

if nhrs is None:
   hrb = input('Enter first hour (normally 0): ')
   hre = input('Enter last hour: ')
   step = input('Enter hourly step: ')
   nhrs = np.arange(hrb,hre+1,step)


print 'Array of hours is: '
print nhrs

date_list = [date_str + datetime.timedelta(hours=x) for x in nhrs]


# Loop through date list to extract and rename analysis files
for j in range(len(date_list)):

   YYYYMMDDCC = date_list[j].strftime("%Y%m%d%H")
   print "Getting "+YYYYMMDDCC+" "+anl_str+" analysis"

   if str.upper(anl_str) != 'FV3' and str.upper(anl_str) != 'NAM3' and str.upper(anl_str) != 'EC':
      RH_PREFIX = RH_PRE+'rh'+YYYYMMDDCC[0:4]+'/'+YYYYMMDDCC[0:6]+'/'+YYYYMMDDCC[0:8]

   if str.upper(anl_str) == 'ST4':
      os.system('htar -xvf '+RH_PREFIX+'/'+TAR_PREFIX+YYYYMMDDCC[0:8]+TAR_SUFFIX+' ./'+FILE_PREFIX+YYYYMMDDCC+FILE_SUFFIX)
      os.system('gunzip ./'+FILE_PREFIX+YYYYMMDDCC+FILE_SUFFIX)

   elif str.upper(anl_str) == 'RADAR' or str.upper(anl_str) == 'REFD':
      FILE_PREFIX2 = 'refd3d.'+YYYYMMDDCC[0:8]+'.t'
      os.system('htar -xvf '+RH_PREFIX+'/'+TAR_PREFIX+YYYYMMDDCC[0:8]+TAR_SUFFIX+' ./'+FILE_PREFIX+YYYYMMDDCC[8:]+FILE_SUFFIX)
      os.system('mv ./'+FILE_PREFIX+YYYYMMDDCC[8:]+FILE_SUFFIX+' ./'+FILE_PREFIX2+YYYYMMDDCC[8:]+FILE_SUFFIX)

   elif str.upper(anl_str) == 'RTMA' or str.upper(anl_str) == 'URMA':
      if str.upper(anl_str) == 'RTMA':
         FILE_PREFIX2 = 'rtma2p5.'+YYYYMMDDCC[0:8]+'.t'
      elif str.upper(anl_str) == 'URMA':
         FILE_PREFIX2 = 'urma2p5.'+YYYYMMDDCC[0:8]+'.t'

      if int(YYYYMMDDCC[8:]) <= 5:
         TAR_SUFFIX  = '00-05.tar'
      elif int(YYYYMMDDCC[8:]) >= 6 and int(YYYYMMDDCC[8:]) <= 11:
         TAR_SUFFIX  = '06-11.tar'
      elif int(YYYYMMDDCC[8:]) >= 12 and int(YYYYMMDDCC[8:]) <= 17:
         TAR_SUFFIX  = '12-17.tar'
      elif int(YYYYMMDDCC[8:]) >= 18 and int(YYYYMMDDCC[8:]) <= 23:
         TAR_SUFFIX  = '18-23.tar'
      
      os.system('htar -xvf '+RH_PREFIX+'/'+TAR_PREFIX+YYYYMMDDCC[0:8]+TAR_SUFFIX+' ./'+FILE_PREFIX+YYYYMMDDCC[8:]+FILE_SUFFIX)
      os.system('mv ./'+FILE_PREFIX+YYYYMMDDCC[8:]+FILE_SUFFIX+' ./'+FILE_PREFIX2+YYYYMMDDCC[8:]+FILE_SUFFIX)

   elif str.upper(anl_str) == 'GFS':
      FILE  = 'gfs.t'+YYYYMMDDCC[8:10]+'z.pgrb2.0p25.f000'
      FILE2 = 'gfs.'+YYYYMMDDCC[0:8]+'.t'+YYYYMMDDCC[8:10]+'z.pgrb2.0p25.f000'
      os.system('htar -xvf '+RH_PREFIX+'/'+TAR_PREFIX+YYYYMMDDCC+TAR_SUFFIX+' ./'+FILE)
      os.system('mv ./'+FILE+' ./'+FILE2)

   elif str.upper(anl_str) == 'EC':
      RH_PREFIX = '/NCEPDEV/emc-global/5year/emc.glopara/stats/ecm/'
 # TAR_PREFIX  = 'ecm'
 # TAR_SUFFIX  = '.tar'
      FILE  = 'pgbf00.ecm.'+YYYYMMDDCC
      FILE2 = 'ec.'+YYYYMMDDCC[0:8]+'.t'+YYYYMMDDCC[8:10]+'z.pgbf000'
      os.system('htar -xvf '+RH_PREFIX+TAR_PREFIX+YYYYMMDDCC[8:10]+'_'+YYYYMMDDCC[0:6]+TAR_SUFFIX+' '+FILE)
      os.system('mv ./'+FILE+' ./'+FILE2)


   elif str.upper(anl_str) == 'FV3':
    # RH_PREFIX = '/NCEPDEV/emc-global/1year/emc.glopara/WCOSS_C/scratch/prfv3l65'   # old path to experiment with GFS ICs and GFDL MP
    # RH_PREFIX = '/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_C/Q1FY19/prfv3rt1'    # new path to fully-cycled experiment
      RH_PREFIX = '/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_C/Q2FY19/prfv3rt1'    # new path to fully-cycled experiment
      FILE  = 'gfs.t'+YYYYMMDDCC[8:10]+'z.pgrb2.0p25.f000'
      FILE2 = 'fv3.'+YYYYMMDDCC[0:8]+'.t'+YYYYMMDDCC[8:10]+'z.pgrb2.0p25.f000'
    # os.system('htar -xvf '+RH_PREFIX+'/'+YYYYMMDDCC+'/'+TAR_FILE+' gfs/'+FILE)
    # os.system('mv gfs/'+FILE+' ./'+FILE2)
      os.system('htar -xvf '+RH_PREFIX+'/'+YYYYMMDDCC+'/'+TAR_FILE+ \
                ' ./gfs.'+YYYYMMDDCC[0:8]+'/'+YYYYMMDDCC[8:10]+'/'+FILE)
      os.system('mv ./gfs.'+cycle[0:8]+'/'+cycle[8:10]+'/'+FILE+ \
                ' ./'+FILE2)

      if TAR_PREFIX == 'gfsa.':
         os.system('rm -fR ./gfs.'+cycle[0:8]+'/'+cycle[8:10]+'/')

   elif str.upper(anl_str) == 'NAM':
      if nam_resolution == '12':
         FILE  = 'nam.t'+YYYYMMDDCC[8:10]+'z.awip1200.tm00.grib2'
         FILE2 = 'nam.'+YYYYMMDDCC[0:8]+'.t'+YYYYMMDDCC[8:10]+'z.awip1200.tm00.grib2'
      elif nam_resolution == '32':
         FILE  = 'nam.t'+YYYYMMDDCC[8:10]+'z.awip3200.tm00.grib2'
         FILE2 = 'nam.'+YYYYMMDDCC[0:8]+'.t'+YYYYMMDDCC[8:10]+'z.awip3200.tm00.grib2'
      os.system('htar -xvf '+RH_PREFIX+'/'+TAR_PREFIX+YYYYMMDDCC+TAR_SUFFIX+' ./'+FILE)
      os.system('mv ./'+FILE+' ./'+FILE2)

   elif str.upper(anl_str) == 'NAM3':
      RH_PREFIX = RH_PRE+'2year/rh'+YYYYMMDDCC[0:4]+'/'+YYYYMMDDCC[0:6]+'/'+YYYYMMDDCC[0:8]
      FILE  = 'nam.t'+YYYYMMDDCC[8:10]+'z.conusnest.hiresf00.tm00.grib2'
      FILE2 = 'nam.'+YYYYMMDDCC[0:8]+'.t'+YYYYMMDDCC[8:10]+'z.conusnest.hiresf00.tm00.grib2'
      os.system('htar -xvf '+RH_PREFIX+'/'+TAR_PREFIX+YYYYMMDDCC+TAR_SUFFIX+' ./'+FILE)
      os.system('mv ./'+FILE+' ./'+FILE2)


   elif str.upper(anl_str) == 'RAP' or str.upper(anl_str) == 'HRRR':
      if str.upper(anl_str) == 'RAP':
         FILE_PREFIX2 = 'rap.'+YYYYMMDDCC[0:8]+'.t'
      elif str.upper(anl_str) == 'HRRR':
         FILE_PREFIX2 = 'hrrr.'+YYYYMMDDCC[0:8]+'.t'

      if int(YYYYMMDDCC[8:]) <= 5:
         TAR_SUFFIX  = '00-05.wrf.tar'
         TAR_SUFFIX  = '00-05.awp130.tar'
      elif int(YYYYMMDDCC[8:]) >= 6 and int(YYYYMMDDCC[8:]) <= 11:
         TAR_SUFFIX  = '06-11.wrf.tar'
         TAR_SUFFIX  = '06-11.awp130.tar'
      elif int(YYYYMMDDCC[8:]) >= 12 and int(YYYYMMDDCC[8:]) <= 17:
         TAR_SUFFIX  = '12-17.wrf.tar'
         TAR_SUFFIX  = '12-17.awp130.tar'
      elif int(YYYYMMDDCC[8:]) >= 18 and int(YYYYMMDDCC[8:]) <= 23:
         TAR_SUFFIX  = '18-23.wrf.tar'
         TAR_SUFFIX  = '18-23.awp130.tar'
      
      os.system('htar -xvf '+RH_PREFIX+'/'+TAR_PREFIX+YYYYMMDDCC[0:8]+TAR_SUFFIX+' ./'+FILE_PREFIX+YYYYMMDDCC[8:]+FILE_SUFFIX)
      os.system('mv ./'+FILE_PREFIX+YYYYMMDDCC[8:]+FILE_SUFFIX+' ./'+FILE_PREFIX2+YYYYMMDDCC[8:]+FILE_SUFFIX)


print "Done"
