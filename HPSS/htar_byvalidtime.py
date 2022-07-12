#!/usr/bin/env python
# Author: L Dawson
#
# Script to pull fcst files by valid time from HPSS, rename, and save in desired data directory
# Desired cycle and model string can be passed in from command line
# If no arguments are passed in, script will prompt user for these inputs
#
# Script History Log:
# 2018-01    L Dawson  initial versioning to pull forecast files. Required command line inputs
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
   cycle = raw_input('Enter forecast valid time (YYYYMMDDHH): ')

yyyy = int(cycle[0:4])
mm   = int(cycle[4:6])
dd   = int(cycle[6:8])
hh   = int(cycle[8:10])

date_str = datetime.datetime(yyyy,mm,dd,hh,0,0)


# Determine desired model
try:
   model_str = str(sys.argv[2])
except IndexError:
   model_str = None

if model_str is None:
   print 'Model string options: GFS, GEFS, FV3, EC, NAM, NAMNEST, RAP, HRRR, HRRRX, HIRESW, or HREF'
   model_str = raw_input('Enter desired model: ')
   ## GEFS options: GEFS, GEFSMEAN, GEFSSPREAD, GEFSCTRL, GEFSMEMS
   ## HREF options: HREF, HREFPROB, HREFMEAN, HREFPMMN, HREFAVRG
   ## HIRESW options: HIRESW, HIRESWARW, HIRESWARW2, HIRESWNMMB

# Set run length values
# GFS and FV3
if str.upper(model_str) == 'GFS' or str.upper(model_str) == 'FV3':
   runlength = 384

# GEFS
elif str.upper(model_str[0:4]) == 'GEFS':
   runlength = 384

   if len(model_str) == 4:
      ens_prod = raw_input('Enter MEAN, SPREAD, CTRL, or MEMS for desired GEFS product file: ')
      model_str = model_str+ens_prod

   grid_res = float(raw_input('Enter 0.5 or 1 for desired grid resolution: '))
   if grid_res != 0.5 and grid_res != 1:
      raise ValueError, 'Must enter 0.5 or 1 for desired resolution'

# EC
elif str.upper(model_str) == 'EC':
   runlength = 240

# NAM
elif str.upper(model_str) == 'NAM':
   runlength = 84

   grid_res = int(raw_input('Enter 12 or 32 for desired grid resolution: '))
   if grid_res != 12 and grid_res != 32:
      raise ValueError, 'Must enter 12 or 32 for desired resolution'

# NAM Nest
elif str.upper(model_str) == 'NAMNEST' or str.upper(model_str) == 'NAM3':
   runlength = 60

# HiResWs
elif str.upper(model_str[0:6]) == 'HIRESW':
   runlength = 48

   if len(model_str) == 6:
      hiresw_member = raw_input('Enter ARW, ARW2, or NMMB for desired HiResW run: ')
      model_str = model_str+hiresw_member

# HREF
elif str.upper(model_str[0:4]) == 'HREF':
   runlength = 36

   if len(model_str) == 8:
      ens_prod = model_str[4:]
   elif len(model_str) == 4:
      ens_prod = raw_input('Enter PROB, MEAN, PMMN, or AVRG for desired HREF product file: ')
      model_str = model_str+ens_prod

# RAP
elif str.upper(model_str) == 'RAP':
   runlength = 21

# HRRR
elif str.upper(model_str) == 'HRRR':
   runlength = 18

# HRRRX
elif str.upper(model_str) == 'HRRRX':
   if cycle[8:] == '00' or cycle[8:] == '06' or cycle[8:] == '12' or cycle[8:] == '18':
      runlength = 36
   else:   
      runlength = 18

# RAPX
elif str.upper(model_str) == 'RAPX':
   if cycle[8:] == '00' or cycle[8:] == '06' or cycle[8:] == '12' or cycle[8:] == '18':
      runlength = 39
   else:   
      runlength = 21


### By default, will ask for command line input to determine which analysis files to pull 
### User can uncomment and modify the next two line to bypass the command line calls
nhrs = [-144, -120, -96, -72, -36, -12, 0]
fhrs = [nhr*-1 for nhr in nhrs] 

try:
   nhrs
except NameError:
   nhrs = None

if nhrs is None:
   fhrb = np.absolute(int(raw_input('Enter oldest forecast hour: ')))
   if fhrb > runlength:
      raise ValueError, 'Invalid run length. Oldest forecast hour cannot be more than '+str(runlength) 

   fhre = np.absolute(int(raw_input('Enter most recent forecast hour (usually 0): ')))

   step = int(raw_input('Enter hourly step: '))
   if (str.upper(model_str) == 'EC' or str.upper(model_str[0:4]) == 'HREF' or str.upper(model_str[0:6]) == 'HIRESW') and step%12 != 0:
      step = 12
      print 'Invalid '+model_str+' step. Setting step to '+str(step)
   elif (str.upper(model_str) == 'GFS' or str.upper(model_str) == 'GEFS' or str.upper(model_str) == 'FV3' or str.upper(model_str[0:3]) == 'NAM') and step%6 !=0:
      step = 6
      print 'Invalid '+model_str+' step. Setting step to '+str(step)
   else:
      if step <= 0:
         raise ValueError, 'Hourly step muste be greater than or equal to 1 for '+str.upper(model_str) 

   fhrs = np.arange(fhre,fhrb+1,step)
   fhrs = fhrs[::-1]
   nhrs = fhrs*-1

print 'Array of hours is: '
print nhrs

date_list = [date_str + datetime.timedelta(hours=x) for x in nhrs]


# Loop through
for nf in range(len(date_list)):
    YYYYMMDDCC  = date_list[nf].strftime("%Y%m%d%H")
    YYYYMMDD_CC = date_list[nf].strftime("%Y%m%d_%H")

    print "Getting "+str(fhrs[nf])+"-h forecast from "+YYYYMMDDCC+" "+model_str+" cycle"

    # Set prefix for correct runhistory path
    if str.upper(model_str) == 'GFS' or str.upper(model_str) == 'NAM' or str.upper(model_str) == 'SREF' or str.upper(model_str) == 'RAP' or str.upper(model_str) == 'HRRR':
       RH_PREFIX = '/NCEPPROD/hpssprod/runhistory/rh'+YYYYMMDDCC[0:4]+'/'+YYYYMMDDCC[0:6]+'/'+YYYYMMDDCC[0:8]

    elif str.upper(model_str) == 'NAM3' or str.upper(model_str) == 'NAMNEST' or str.upper(model_str[0:4]) == 'HREF' or str.upper(model_str[0:6]) == 'HIRESW':
       RH_PREFIX = '/NCEPPROD/hpssprod/runhistory/2year/rh'+YYYYMMDDCC[0:4]+'/'+YYYYMMDDCC[0:6]+'/'+YYYYMMDDCC[0:8]

    elif str.upper(model_str) == 'FV3':
     # RH_PREFIX = '/NCEPDEV/emc-global/1year/emc.glopara/WCOSS_C/scratch/prfv3l65'   # old path to experiment with GFS ICs and GFDL MP
       RH_PREFIX = '/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_C/Q1FY19/prfv3rt1'    # new path to fully-cycled experiment

    elif str.upper(model_str) == 'EC':
       RH_PREFIX = '/NCEPDEV/emc-global/5year/emc.glopara/stats/ecm/'

    elif str.upper(model_str) == 'HRRRX':
       RH_PREFIX = '/NCEPDEV/emc-meso/1year/Benjamin.Blake/hrrrv3/'

    elif str.upper(model_str) == 'RAPX':
       RH_PREFIX = '/NCEPDEV/emc-meso/1year/Benjamin.Blake/rapv4/'


    # GFS
    if str.upper(model_str) == 'GFS':
       TAR_PREFIX   = 'gpfs_hps_nco_ops_com_gfs_prod_gfs.'
       TAR_SUFFIX   = '.pgrb2_0p25.tar'
     # TAR_SUFFIX   = '.pgrb2_0p50.tar'                        # uncomment if 0.5 degree data are desired
       FILE_PREFIX  = 'gfs.t'+YYYYMMDDCC[8:10]+'z.'
       FILE_PREFIX2 = 'gfs.'+YYYYMMDDCC[0:8]+'.t'+YYYYMMDDCC[8:10]+'z.'
       FILE_SUFFIX  = 'pgrb2.0p25.f'
     # FILE_SUFFIX  = 'pgrb2.0p50.f'                           # uncomment if 0.5 degree data are desired
       os.system('htar -xvf '+RH_PREFIX+'/'+TAR_PREFIX+YYYYMMDDCC+TAR_SUFFIX+' ./'+FILE_PREFIX+FILE_SUFFIX+str(fhrs[nf]).zfill(3))
       os.system('mv ./'+FILE_PREFIX+FILE_SUFFIX+str(fhrs[nf]).zfill(3)+' ./'+FILE_PREFIX2+FILE_SUFFIX+str(fhrs[nf]).zfill(3))

    # FV3 forecasts
    elif str.upper(model_str) == 'FV3':
       TAR_PREFIX   = 'gfs.'
       TAR_SUFFIX   = 'tar'
       FILE_PREFIX  = 'gfs.t'+YYYYMMDDCC[8:10]+'z.'
       FILE_PREFIX2 = 'fv3.'+YYYYMMDDCC[0:8]+'.t'+YYYYMMDDCC[8:10]+'z.'
       FILE_SUFFIX  = 'pgrb2.0p25.f'
     # os.system('htar -xvf '+RH_PREFIX+'/'+YYYYMMDDCC+'/'+TAR_PREFIX+TAR_SUFFIX+' gfs/'+FILE_PREFIX+FILE_SUFFIX+str(fhrs[nf]).zfill(3))  # old structure for GFS IC exp
     # os.system('mv gfs/'+FILE_PREFIX+FILE_SUFFIX+str(fhrs[nf]).zfill(3)+' ./'+FILE_PREFIX2+FILE_SUFFIX+str(fhrs[nf]).zfill(3))          # old structure for GFS IC exp
       os.system('htar -xvf '+RH_PREFIX+'/'+YYYYMMDDCC+'/'+TAR_PREFIX+TAR_SUFFIX+' ./gfs.'+YYYYMMDDCC[0:8]+'/'+YYYYMMDDCC[8:10]+'/'+FILE_PREFIX+FILE_SUFFIX+str(fhrs[nf]).zfill(3))
       os.system('mv ./gfs.'+YYYYMMDDCC[0:8]+'/'+YYYYMMDDCC[8:10]+'/'+FILE_PREFIX+FILE_SUFFIX+str(fhrs[nf]).zfill(3)+' ./'+FILE_PREFIX2+FILE_SUFFIX+str(fhrs[nf]).zfill(3))



    # GEFS forecasts
    elif str.upper(model_str[0:4]) == 'GEFS':
       TAR_PREFIX = 'com2_gens_prod_gefs.'

       if str.upper(model_str[4:]) == 'MEAN':
          FILE_PREFIX  = 'geavg.t'
          FILE_PREFIX2 = 'geavg.'+YYYYMMDDCC[0:8]+'.t'
       elif str.upper(model_str[4:]) == 'SPREAD':
          FILE_PREFIX  = 'gespr.t'
          FILE_PREFIX2 = 'gespr.'+YYYYMMDDCC[0:8]+'.t'
       elif str.upper(model_str[4:]) == 'CTRL':
          FILE_PREFIX  = 'gec00.t'
          FILE_PREFIX2 = 'gec00.'+YYYYMMDDCC[0:8]+'.t'

       if grid_res == 0.5:
          RH_PREFIX = '/NCEPPROD/hpssprod/runhistory/2year/rh'+YYYYMMDDCC[0:4]+'/'+YYYYMMDDCC[0:6]+'/'+YYYYMMDDCC[0:8]
          TEMP_DIR = 'pgrb2ap5'
          TAR_SUFFIX = '.pgrb2ap5.tar'
          FILE_SUFFIX = 'z.pgrb2a.0p50.f'

       elif grid_res == 1:
          RH_PREFIX = '/NCEPPROD/hpssprod/runhistory/rh'+YYYYMMDDCC[0:4]+'/'+YYYYMMDDCC[0:6]+'/'+YYYYMMDDCC[0:8]
          TEMP_DIR = 'pgrb2a'
          TAR_SUFFIX = '.pgrb2a.tar'
          FILE_SUFFIX = 'z.pgrb2af'


       if grid_res == 1 and fhrs[nf] < 100:
          digits = 2
       else:
          digits = 3

       if str.upper(model_str[4:7]) != 'MEM':
          os.system('htar -xvf '+RH_PREFIX+'/'+TAR_PREFIX+YYYYMMDD_CC+TAR_SUFFIX+' ./'+TEMP_DIR+'/'+FILE_PREFIX+YYYYMMDDCC[8:]+FILE_SUFFIX+str(fhrs[nf]).zfill(digits))
          os.system('mv ./'+TEMP_DIR+'/'+FILE_PREFIX+YYYYMMDDCC[8:]+FILE_SUFFIX+str(fhrs[nf]).zfill(digits)+' ./'+FILE_PREFIX2+YYYYMMDDCC[8:]+FILE_SUFFIX+str(fhrs[nf]).zfill(3))

       elif str.upper(model_str[4:7]) == 'MEM':
          for k in range(1,21):
              print "Getting "+str(fhrs[nf]).zfill(3)+"-h forecast for "+YYYYMMDDCC+" GEFS mem "+str(k)+" ("+str(grid_res)+" deg)"
              os.system('htar -xvf '+RH_PREFIX+'/'+TAR_PREFIX+YYYYMMDD_CC+TAR_SUFFIX+ \
                        ' ./'+TEMP_DIR+'/gep'+str(k).zfill(2)+'.t'+YYYYMMDDCC[8:]+FILE_SUFFIX+str(fhrs[nf]).zfill(digits))
              os.system('mv ./'+TEMP_DIR+'/gep'+str(k).zfill(2)+'.t'+YYYYMMDDCC[8:]+FILE_SUFFIX+str(fhrs[nf]).zfill(digits)+ \
                        ' ./gep'+str(k).zfill(2)+'.'+YYYYMMDDCC[0:8]+'.t'+YYYYMMDDCC[8:]+FILE_SUFFIX+str(fhrs[nf]).zfill(3))


    # EC forecasts
    elif str.upper(model_str) == 'EC':
       TAR_PREFIX  = 'ecm'+YYYYMMDDCC[8:]+'_'
       TAR_SUFFIX  = YYYYMMDDCC[0:6]+'.tar'
       FILE_PREFIX = 'pgbf'
       FILE_SUFFIX = '.ecm.'+YYYYMMDDCC
       FILE_PREFIX2 = 'ec.'+YYYYMMDDCC[0:8]+'.t'+YYYMMDDCC[8:]+'z.'
       FILE_SUFFIX2 = 'pgbf'

       print 'htar -xvf '+RH_PREFIX+TAR_PREFIX+TAR_SUFFIX+' ./'+FILE_PREFIX+str(fhrs[nf])+FILE_SUFFIX
       os.system('htar -xvf '+RH_PREFIX+TAR_PREFIX+TAR_SUFFIX+' ./'+FILE_PREFIX+str(fhrs[nf])+FILE_SUFFIX)
       print 'mv ./'+FILE_PREFIX+str(fhrs[nf])+FILE_SUFFIX+' ./'+FILE_PREFIX2+FILE_SUFFIX2+str(fhrs[nf]).zfill(3)
       os.system('mv ./'+FILE_PREFIX+str(fhrs[nf])+FILE_SUFFIX+' ./'+FILE_PREFIX2+FILE_SUFFIX2+str(fhrs[nf]).zfill(3))


    # NAM forecasts
    elif str.upper(model_str) == 'NAM':
       TAR_PREFIX   = 'com2_nam_prod_nam.'

       if grid_res == 12:
          TAR_SUFFIX   = '.awip.tar'
          FILE_PREFIX  = 'nam.t'+YYYYMMDDCC[8:10]+'z.awip12'
          FILE_PREFIX2 = 'nam.'+YYYYMMDDCC[0:8]+'.t'+YYYYMMDDCC[8:10]+'z.awip12'
       elif grid_res == 32:
          TAR_SUFFIX   = '.awip32.tar'
          FILE_PREFIX  = 'nam.t'+YYYYMMDDCC[8:10]+'z.awip32'
          FILE_PREFIX2 = 'nam.'+YYYYMMDDCC[0:8]+'.t'+YYYYMMDDCC[8:10]+'z.awip32'

       FILE_SUFFIX  = '.tm00.grib2'
       os.system('htar -xvf '+RH_PREFIX+'/'+TAR_PREFIX+YYYYMMDDCC+TAR_SUFFIX+' ./'+FILE_PREFIX+str(fhrs[nf]).zfill(2)+FILE_SUFFIX)
       os.system('mv ./'+FILE_PREFIX+str(fhrs[nf]).zfill(2)+FILE_SUFFIX+' ./'+FILE_PREFIX2+str(fhrs[nf]).zfill(2)+FILE_SUFFIX)


    # NAM3 forecasts
    elif str.upper(model_str) == 'NAM3' or str.upper(model_str) == 'NAMNEST':
       TAR_PREFIX   = 'com2_nam_prod_nam.'
       TAR_SUFFIX   = '.conusnest.tar'
       FILE_PREFIX  = 'nam.t'+YYYYMMDDCC[8:10]+'z.conusnest.hiresf'
       FILE_PREFIX2 = 'nam.'+YYYYMMDDCC[0:8]+'.t'+YYYYMMDDCC[8:10]+'z.conusnest.hiresf'
       FILE_SUFFIX  = '.tm00.grib2'
       os.system('htar -xvf '+RH_PREFIX+'/'+TAR_PREFIX+YYYYMMDDCC+TAR_SUFFIX+' ./'+FILE_PREFIX+str(fhrs[nf]).zfill(2)+FILE_SUFFIX)
       os.system('mv ./'+FILE_PREFIX+str(fhrs[nf]).zfill(2)+FILE_SUFFIX+' ./'+FILE_PREFIX2+str(fhrs[nf]).zfill(2)+FILE_SUFFIX)


    # SREF forecasts
    elif str.upper(model_str) == 'SREF':
       TAR_PREFIX = 'com2_sref_prod_sref.'
       TAR_SUFFIX = 'com_hiresw_prod_hiresw.'

    # HREF forecasts
    elif str.upper(model_str[0:4]) == 'HREF':
       TAR_PREFIX = 'gpfs_hps_nco_ops_com_hiresw_prod_href.'
       TAR_SUFFIX = '_ensprod.tar'
       FILE_PREFIX  = 'href.t'+YYYYMMDDCC[8:10]+'z.conus.'+str.lower(ens_prod)+'.f'
       FILE_PREFIX2 = 'href.'+YYYYMMDDCC[0:8]+'.t'+YYYYMMDDCC[8:10]+'z.conus.'+str.lower(ens_prod)+'.f'
       FILE_SUFFIX  = '.grib2'

       os.system('htar -xvf '+RH_PREFIX+'/'+TAR_PREFIX+YYYYMMDDCC[0:8]+TAR_SUFFIX+' ./'+FILE_PREFIX+str(fhrs[nf]).zfill(2)+FILE_SUFFIX)
       os.system('mv ./'+FILE_PREFIX+str(fhrs[nf]).zfill(2)+FILE_SUFFIX+' ./'+FILE_PREFIX2+str(fhrs[nf]).zfill(2)+FILE_SUFFIX)

    # HIRESW forecasts
    elif str.upper(model_str[0:6]) == 'HIRESW':
        TAR_PREFIX = 'com_hiresw_prod_hiresw.'
        TAR_SUFFIX = '.5km.tar'

        if str.upper(model_str[6:]) == 'ARW':
           FILE_PREFIX  = 'hiresw.t'+YYYYMMDDCC[8:10]+'z.arw_5km.f'
           FILE_PREFIX2 = 'hiresw.'+YYYYMMDDCC[0:8]+'.t'+YYYYMMDDCC[8:10]+'z.arw_5km.f'
           FILE_SUFFIX  = '.conus.grib2'
        elif str.upper(model_str[6:]) == 'NMMB':
           FILE_PREFIX  = 'hiresw.t'+YYYYMMDDCC[8:10]+'z.nmmb_5km.f'
           FILE_PREFIX2 = 'hiresw.'+YYYYMMDDCC[0:8]+'.t'+YYYYMMDDCC[8:10]+'z.nmmb_5km.f'
           FILE_SUFFIX  = '.conus.grib2'
        elif str.upper(model_str[6:]) == 'ARW2':
           FILE_PREFIX  = 'hiresw.t'+YYYYMMDDCC[8:10]+'z.arw_5km.f'
           FILE_PREFIX2 = 'hiresw.'+YYYYMMDDCC[0:8]+'.t'+YYYYMMDDCC[8:10]+'z.arw_5km.f'
           FILE_SUFFIX  = '.conusmem2.grib2'

        os.system('htar -xvf '+RH_PREFIX+'/'+TAR_PREFIX+YYYYMMDDCC[0:8]+TAR_SUFFIX+' ./'+FILE_PREFIX+str(fhrs[nf]).zfill(2)+FILE_SUFFIX)
        os.system('htar -xvf '+RH_PREFIX+'/'+TAR_PREFIX+YYYYMMDDCC[0:8]+TAR_SUFFIX+' ./'+FILE_PREFIX+str(fhrs[nf]).zfill(2)+FILE_SUFFIX)

    # RAP/HRRR forecasts
    elif str.upper(model_str) == 'RAP' or str.upper(model_str) == 'HRRR':
       if str.upper(model_str) == 'RAP':
          TAR_PREFIX   = 'com2_rap_prod_rap.'
          FILE_PREFIX  = 'rap.t'+YYYYMMDDCC[8:10]+'z.awp130pgrbf'
          FILE_PREFIX2 = 'rap.'+YYYYMMDDCC[0:8]+'.t'+YYYYMMDDCC[8:10]+'z.awp130pgrbf'
          FILE_SUFFIX  = '.grib2'

          if int(YYYYMMDDCC[8:]) <= 5:
             TAR_SUFFIX  = '00-05.awp130.tar'
          elif int(YYYYMMDDCC[8:]) >= 6 and int(YYYYMMDDCC[8:]) <= 11:
             TAR_SUFFIX  = '06-11.awp130.tar'
          elif int(YYYYMMDDCC[8:]) >= 12 and int(YYYYMMDDCC[8:]) <= 17:
             TAR_SUFFIX  = '12-17.awp130.tar'
          elif int(YYYYMMDDCC[8:]) >= 18 and int(YYYYMMDDCC[8:]) <= 23:
             TAR_SUFFIX  = '18-23.awp130.tar'

       elif str.upper(model_str) == 'HRRR':
          TAR_PREFIX   = 'com2_hrrr_prod_hrrr.'
          FILE_PREFIX  = 'hrrr.t'+YYYYMMDDCC[8:10]+'z.wrfprsf'
          FILE_PREFIX2 = 'hrrr.'+YYYYMMDDCC[0:8]+'.t'+YYYYMMDDCC[8:10]+'z.wrfprsf'
          FILE_SUFFIX   = '.grib2'

          if int(YYYYMMDDCC[8:]) <= 5:
             TAR_SUFFIX  = '00-05.wrf.tar'
          elif int(YYYYMMDDCC[8:]) >= 6 and int(YYYYMMDDCC[8:]) <= 11:
             TAR_SUFFIX  = '06-11.wrf.tar'
          elif int(YYYYMMDDCC[8:]) >= 12 and int(YYYYMMDDCC[8:]) <= 17:
             TAR_SUFFIX  = '12-17.wrf.tar'
          elif int(YYYYMMDDCC[8:]) >= 18 and int(YYYYMMDDCC[8:]) <= 23:
             TAR_SUFFIX  = '18-23.wrf.tar'

       os.system('htar -xvf '+RH_PREFIX+'/'+TAR_PREFIX+YYYYMMDDCC[0:8]+TAR_SUFFIX+' ./'+FILE_PREFIX+str(fhrs[nf]).zfill(2)+FILE_SUFFIX)
       os.system('mv ./'+FILE_PREFIX+str(fhrs[nf]).zfill(2)+FILE_SUFFIX+' ./'+FILE_PREFIX2+str(fhrs[nf]).zfill(2)+FILE_SUFFIX)


    # HRRRX forecasts
    elif str.upper(model_str) == 'HRRRX':
       TAR_PREFIX   = 'hrrr.'+YYYYMMDDCC
       TAR_SUFFIX   = '.tar'
       FILE_PREFIX  = 'hrrr.t'+YYYYMMDDCC[8:10]+'z.wrfprsf'
       FILE_PREFIX2 = 'hrrrx.'+YYYYMMDDCC[0:8]+'.t'+YYYYMMDDCC[8:10]+'z.wrfprsf'
       FILE_SUFFIX  = '.grib2'
       os.system('htar -xvf '+RH_PREFIX+'hrrr.'+YYYYMMDDCC[0:8]+'/'+TAR_PREFIX+TAR_SUFFIX+' ./'+FILE_PREFIX+str(fhrs[nf]).zfill(2)+FILE_SUFFIX)
       os.system('mv ./'+FILE_PREFIX+str(fhrs[nf]).zfill(2)+FILE_SUFFIX+' ./'+FILE_PREFIX2+str(fhrs[nf]).zfill(2)+FILE_SUFFIX)









print "Done"
