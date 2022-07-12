# Author: L Dawson
#
# Run as:
# python parse_FV3GFS.py $MODEL $TC_name/ID
# python parse_FV3GFS.py FV3GFS FlorenceAL06
#
# Script History Log:
# 2018-11-19 L Dawson Made script edits to share code


import numpy as np
import datetime, os, sys, subprocess
import re, csv, glob


# Determine desired model
try:
   model_str = str(sys.argv[1])
except IndexError:
   model_str = None

if model_str is None:
   print 'Model string options: FV3GFS'
   model_str = raw_input('Enter desired model: ')


model = model_str


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

# Get list of cycles based on matching files in DATA_DIR
filelist = [f for f in glob.glob(DATA_DIR+'/atcfunix.gfs.*')]



cycles_unordered = [filelist[x][-10:] for x in xrange(len(filelist))]
cycles_int = [int(x) for x in cycles_unordered]
cycles_int.sort()
cycles = [str(x) for x in cycles_int]

print cycles

for cycle in cycles:

   # lat/lon lists for each model
   fhrs=[]
   lats=[]
   lons=[]
   vmax=[]
   pres=[]

   track_file = DATA_DIR+'/atcfunix.gfs.'+cycle

   with open(track_file,'r') as ofile:
      reader=csv.reader(ofile)
      for row in reader:
         if row[0].replace(" ","")==str.upper(TC_number[0:2]) and row[1].replace(" ","")==TC_number[2:4] and row[11].replace(" ","") == '34':
            if int(row[5]) <= 180:      # shorten tracks to F180 to match GFS a-deck
               fhrs.append(int(row[5].replace(" ","")))
               lats.append(float(re.sub("N","",row[6]))/10.0)
               try:
                  lons.append(float(re.sub("W","",row[7]))/-10.0)
               except:
                  lons.append(float(re.sub("E","",row[7]))/10.0)
               vmax.append(row[8].replace(" ",""))
               pres.append(row[9].replace(" ",""))
           

   if len(fhrs) > 0:

      f = open(DATA_DIR+'/'+str.lower(TC_name)+'_'+str.lower(model_str)+'_'+cycle+'.csv','wt')

      cycle_time = datetime.datetime(int(cycle[0:4]),int(cycle[4:6]),int(cycle[6:8]),int(cycle[8:10]))

      i = 0
      try:
         writer = csv.writer(f)
         while i < len(fhrs):
            valid_time = cycle_time + datetime.timedelta(hours=int(fhrs[i]))
            writer.writerow([fhrs[i],valid_time.strftime('%Y%m%d%H'),lats[i],lons[i],pres[i],vmax[i]])
            i += 1

      finally:
         f.close()





