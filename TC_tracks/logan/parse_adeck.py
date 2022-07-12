# Author: L Dawson
#
# Run as:
# python parse_adeck.py $MODEL $TC_name/ID
# python parse_adeck.py GFS FlorenceAL06
#
# Script History Log:
# 2018-11-19 L Dawson Made script edits to share code


import numpy as np
import datetime, os, sys, subprocess
import re, csv


# Determine desired model
try:
   model_str = str(sys.argv[1])
except IndexError:
   model_str = None

if model_str is None:
   print 'Model string options: GFS, AVNO, EC, ECMWF, EMX, UKMet, EGRR, CMC, HWRF, HMON, NAM'
   print 'Model string options (early): AVNI, CMCI, HWFI, HMNI'
   print 'Model string options (ensemble mean): GEFSMean, ECENSmean'
   model_str = raw_input('Enter desired model: ')


if str.upper(model_str) == 'GFS':
   model = 'AVNO'
elif str.upper(model_str) == 'EC' or str.upper(model_str) == 'ECMWF':
   model = 'ECMO'
elif str.upper(model_str) == 'UKMET':
   model = 'EGRR'
elif str.upper(model_str) == 'GEFSMEAN':
   model = 'AEMN'
elif str.upper(model_str) == 'ECENSMEAN':
   model = 'EEMN'
else:
   model = model_str


if str.upper(model_str) == 'UKMET':
   wind_id = '0'
else:
   wind_id = '34'

# Get TC name and number
try:
   TC = str(sys.argv[2])
except IndexError:
   TC = None

if TC is None:
   print 'Enter TC name and number as one string'
   print 'Example: FlorenceAL06'
   TC = raw_input('Enter TC name/number: ')

TC_name = TC[:-4]
TC_number = TC[-4:]
print TC_name, TC_number


# Set DATA_DIR to some directory in your own work space
DATA_DIR = os.path.join('/meso/noscrub/Logan.Dawson/MEG/', TC_name, 'data')

if not os.path.exists(DATA_DIR):
      os.makedirs(DATA_DIR)


cycles=[]
fhrs=[]
lats=[]
lons=[]
vmax=[]
pres=[]
#rmw=[]


#with open('/gpfs/hps3/nhc/noscrub/data/atcf-noaa/aid_nws/a'+str.lower(TC_number)+'2018.dat','r') as f:
with open('/nhc/noscrub/data/atcf-noaa/aid_nws/a'+str.lower(TC_number)+'2018.dat','r') as f:
   reader = csv.reader(f)
   for row in reader:
      if row[4].replace(" ","") == str.upper(model) and row[11].replace(" ","") == wind_id:   # needs to be '0' for UKMet
         thislat = row[6].replace(" ","")
         thislon = row[7].replace(" ","")

         cycles.append(row[2].replace(" ",""))
         fhrs.append(row[5].replace(" ",""))
         lats.append(float(re.sub("N","",thislat))/10.0)
         try:
            lons.append(float(re.sub("W","",thislon))/-10.0)
         except:
            lons.append(float(re.sub("E","",thislon))/10.0)
         vmax.append(row[8].replace(" ",""))
         pres.append(row[9].replace(" ",""))
#        rmw.append(row[19].replace(" ",""))


used=set()
cycles_in_file = [x for x in cycles if x not in used and (used.add(x) or True)]




i = 0
for cycle in cycles_in_file:
   f = open(DATA_DIR+'/'+str.lower(TC_name)+'_'+str.lower(model_str)+'_'+cycle+'.csv','wt')

   cycle_time = datetime.datetime(int(cycle[0:4]),int(cycle[4:6]),int(cycle[6:8]),int(cycle[8:10]))

   try:
      writer = csv.writer(f)
      print cycle, cycles[i]
      while cycle == cycles[i]:
         valid_time = cycle_time + datetime.timedelta(hours=int(fhrs[i]))
      #  writer.writerow([fhrs[i],valid_time.strftime('%Y%m%d%H'),lats[i],lons[i],pres[i],vmax[i],rmw[i]])
         writer.writerow([fhrs[i],valid_time.strftime('%Y%m%d%H'),lats[i],lons[i],pres[i],vmax[i]])
         i += 1

         if i > len(cycles)-1:
            break

   finally:
      f.close()





