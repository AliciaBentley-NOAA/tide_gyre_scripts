# Author: L Dawson
#
# Script to pull fcst files from HPSS, rename, and save in desired data directory
# Desired cycle and model string can be passed in from command line
# If no arguments are passed in, script will prompt user for these inputs
#
# Script History Log:
# 2018-10-03 L Dawson initial version to pull HWRF/HMON ATCF files from tape


import numpy as np
import datetime, os, sys, subprocess
import re

#


# Determine initial date/time
try:
   cycle1 = str(sys.argv[1])
except IndexError:
   cycle1 = None

if cycle1 is None:
   cycle1 = raw_input('Enter first model initialization time (YYYYMMDDHH): ')

YYYY = int(cycle1[0:4])
MM   = int(cycle1[4:6])
DD   = int(cycle1[6:8])
HH   = int(cycle1[8:10])

cycle_date1 = datetime.datetime(YYYY,MM,DD,HH,0,0)

# Determine initial date/time
try:
   cycle2 = str(sys.argv[2])
except IndexError:
   cycle2 = None

if cycle2 is None:
   cycle2 = raw_input('Enter second model initialization time (YYYYMMDDHH): ')

YYYY = int(cycle2[0:4])
MM   = int(cycle2[4:6])
DD   = int(cycle2[6:8])
HH   = int(cycle2[8:10])

cycle_date2 = datetime.datetime(YYYY,MM,DD,HH,0,0)


# Determine desired model
try:
   model_str = str(sys.argv[3])
except IndexError:
   model_str = None

if model_str is None:
   print 'Model string options: GFS, HWRF, HMON'
   model_str = raw_input('Enter desired model: ')

init_inc = 6

# Get list of dates
date_list = []
cycle_date = cycle_date1
while cycle_date <= cycle_date2:
   date_list.append(cycle_date)
   cycle_date += datetime.timedelta(hours=init_inc)


# Get TC name and number
try:
   TC = str(sys.argv[4])
except IndexError:
   TC = None

if TC is None:
   print 'Enter TC name and number as one string'
   print 'Example: FlorenceAL06'
   TC = raw_input('Enter TC name/number: ')

TC_name = TC[:-4]
TC_number = TC[-4:]
print TC_name, TC_number
numbers = 'zero one two three four five six seven eight nine ten'.split()
TC_name_date = datetime.datetime(2018,9,1,12,0,0)


# Set path to data directory
MEG_DIR = os.getcwd()
#if MEG_DIR == '/gpfs/td1/emc/meso/save/Logan.Dawson/MEG' or MEG_DIR =='/gpfs/gd1/emc/meso/save/Logan.Dawson/MEG':
DATA_DIR = os.path.join('/meso/noscrub/Logan.Dawson/MEG/', TC_name, 'data')

if not os.path.exists(DATA_DIR):
   os.makedirs(DATA_DIR)
os.chdir(DATA_DIR)




# Loop through to get files
for j in range(len(date_list)):

   YYYYMMDDCC = date_list[j].strftime("%Y%m%d%H")
   print "Getting "+YYYYMMDDCC+" "+model_str+" ATCF file"

   if str.upper(model_str) == 'HWRF' or str.upper(model_str) == 'HMON':
      RH_PREFIX = '/NCEPPROD/hpssprod/runhistory/2year/rh'+YYYYMMDDCC[0:4]+'/'+str.lower(model_str) + \
                  '/'+TC_number[2:4]+str.lower(TC_number[1])



   # HWRF
   if str.upper(model_str) == 'HWRF':
      
      if date_list[j] < TC_name_date:
         TAR_FILE = str.lower(numbers[int(TC_number[2:4])])+TC_number[2:4]+str.lower(TC_number[1])+'.'+YYYYMMDDCC+'.tar'
         FILE = str.lower(numbers[int(TC_number[2:4])])+TC_number[2:4]+str.lower(TC_number[1])+'.'+YYYYMMDDCC+'.trak.hwrf.atcfunix'

      elif date_list[j] >= TC_name_date:
         TAR_FILE = str.lower(TC_name)+TC_number[2:4]+str.lower(TC_number[1])+'.'+YYYYMMDDCC+'.tar'
         FILE = str.lower(TC_name)+TC_number[2:4]+str.lower(TC_number[1])+'.'+YYYYMMDDCC+'.trak.hwrf.atcfunix'

      os.system('htar -xvf '+RH_PREFIX+'/'+TAR_FILE+' '+FILE)


   # HMON
   elif str.upper(model_str) == 'HMON':
      FILE = TC_number[2:4]+str.upper(TC_number[1])+'.'+YYYYMMDDCC+'.trak.hmon.atcfunix'

      if date_list[j] < TC_name_date:
         TAR_FILE = str.lower(numbers[int(TC_number[2:4])])+TC_number[2:4]+str.lower(TC_number[1])+'.'+YYYYMMDDCC+'.tar'
      elif date_list[j] >= TC_name_date:
         TAR_FILE = str.lower(TC_name)+TC_number[2:4]+str.lower(TC_number[1])+'.'+YYYYMMDDCC+'.tar'

      os.system('htar -xvf '+RH_PREFIX+'/'+TAR_FILE+' '+FILE)




