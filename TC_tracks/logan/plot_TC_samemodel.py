#!/usr/bin/env python

# Run as:
# python plot_TC_samemodel.py $MODEL $TC_name/ID
# python plot_TC_samemodel.py GFS FlorenceAL06
#


import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap, cm
#from matplotlib import GridSpec, rcParams, colors
import matplotlib.gridspec as gridspec
from matplotlib import colors as c
from pylab import *
import numpy as np
import pygrib, datetime, time, os, sys, subprocess
import multiprocessing, itertools, collections
import scipy, ncepy
import re, csv, glob
from ncepgrib2 import Grib2Encode, Grib2Decode



# Determine desired model
try:
   model_str = str(sys.argv[1])
except IndexError:
   model_str = None

if model_str is None:
   print 'Model string options: GFS, FV3GFS, EC, ECMWF, UKMet HWRF, HMON'
   model_str = raw_input('Enter desired model: ')

if str.upper(model_str) == 'EMX' or str.upper(model_str[0:2]) == 'EC':
   model = 'EC'
else:
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


# Set DATA_DIR and GRAPHX_DIR to directories in your own work space
DATA_DIR = os.path.join('/meso/noscrub/Logan.Dawson/MEG/', TC_name, 'data')
GRAPHX_DIR = os.path.join('/ptmpp2/Logan.Dawson/MEG/', TC_name, 'graphx')

if os.path.exists(DATA_DIR):
   if not os.path.exists(GRAPHX_DIR):
      os.makedirs(GRAPHX_DIR)
else:
   raise NameError, 'data for '+TC_name+' not found'


OUT_DIR = GRAPHX_DIR
if not os.path.exists(OUT_DIR):
      os.makedirs(OUT_DIR)


try:
   valid_time
except NameError:
   valid_time = None



# Get list of cycles based on matching files in DATA_DIR
filelist = [f for f in glob.glob(DATA_DIR+'/'+str.lower(TC_name)+'_'+str.lower(model_str)+'*csv')]

cycles_unordered = [filelist[x][-14:-4] for x in xrange(len(filelist))]
cycles_int = [int(x) for x in cycles_unordered]
cycles_int.sort()
cycles = [str(x) for x in cycles_int]


# Get observed data from Best Track file
# Get final valid time by picking last time of TD strength in Best Track file
olat = []
olon = []
opres = []
ovmax = []
otime = []

#with open('/gpfs/hps3/nhc/noscrub/data/atcf-noaa/btk/b'+str.lower(TC_number)+str(YYYY)+'.dat','r') as f:
with open('/nhc/noscrub/data/atcf-noaa/btk/b'+str.lower(TC_number)+cycles[0][0:4]+'.dat','r') as f:
   reader = csv.reader(f)
   for row in reader:
    # if row[27].replace(" ","")==str.upper(TC_name) and (row[11].replace(" ","")=='34' or row[11].replace(" ","")=='0'):
      if row[10].replace(" ","")=='TD' or row[10].replace(" ","")=='TS' or row[10].replace(" ","")=='HU':
         if row[11].replace(" ","")=='34' or row[11].replace(" ","")=='0':
   #        print row
            rowtime=datetime.datetime.strptime(row[2].replace(" ",""),"%Y%m%d%H")

            olat.append(float(re.sub("N","",row[6]))/10.0)
            try:
               olon.append(float(re.sub("W","",row[7]))/-10.0)
            except:
               olon.append(float(re.sub("E","",row[7]))/10.0)
            ovmax.append(float(row[8]))
            opres.append(float(row[9]))
            otime.append(rowtime)




# Get list of dates from first model initialization through final valid time
if str.upper(model_str) == 'UKMET':
   init_inc = 12
else:
   init_inc = 6
date_list = []

first_model_date = datetime.datetime(int(cycles[0][0:4]),int(cycles[0][4:6]),int(cycles[0][6:8]),int(cycles[0][8:10]),0,0)
final_valid_date = otime[-1]
cycle_date = first_model_date

while cycle_date <= final_valid_date:
   date_list.append(cycle_date)
   cycle_date += datetime.timedelta(hours=init_inc)

print date_list[0].strftime('%Y%m%d%H'), date_list[-1].strftime('%Y%m%d%H')


plot_opres=[]
plot_ovmax=[]
k = 1

for j in range(len(date_list)):
   for i in range(len(opres)):
      if otime[i] == date_list[j]:
         plot_opres.append(opres[i])
         plot_ovmax.append(ovmax[i])

   if len(plot_opres) < k: 
      plot_opres.append(np.nan)  
      plot_ovmax.append(np.nan)  

   k += 1

#print len(date_list), len(plot_opres)



# Option to set final valid time to end of Best Track
match_end_bt = False
if match_end_bt:
   valid_time = otime[-1]


mlats=[]
mlons=[]
mpres=[]
mvmax=[]
#mrmw=[]
mtimes=[]

for cycle in cycles:

   YYYY = int(cycle[0:4])
   MM   = int(cycle[4:6])
   DD   = int(cycle[6:8])
   HH   = int(cycle[8:10])
   print YYYY, MM, DD, HH

   cycle_date = datetime.datetime(YYYY,MM,DD,HH,0,0)

   track_file = DATA_DIR+'/'+str.lower(TC_name)+'_'+str.lower(model_str)+'_'+cycle+'.csv' 

   # lat/lon lists for each model
   clat=[]
   clon=[]
   cpres=[]
   cvmax=[]
#  crmw=[]
   ctime=[]

   if os.path.exists(track_file):
      with open(track_file,'r') as f:
         reader=csv.reader(f)
         for row in reader:  
            fcst_time = cycle_date+datetime.timedelta(hours=int(row[0]))
            if valid_time is not None:
               if fcst_time <= valid_time:
                  clat.append(float(row[2]))
                  if float(row[3]) > 0:
                     clon.append(float(row[3])-360)
                  else:
                     clon.append(float(row[3]))
                  cpres.append(float(row[4]))
                  cvmax.append(float(row[5]))
       #          crmw.append(float(row[6]))
                  ctime.append(fcst_time)
            else:
               clat.append(float(row[2]))
               if float(row[3]) > 0:
                  clon.append(float(row[3])-360)
               else:
                  clon.append(float(row[3]))
               cpres.append(float(row[4]))
               cvmax.append(float(row[5]))
       #       crmw.append(float(row[6]))
               ctime.append(fcst_time)


      mlats.append(clat)
      mlons.append(clon)
      mpres.append(cpres)
      mvmax.append(cvmax)
#     mrmw.append(crmw)
      mtimes.append(ctime)


plot_mpres=[]
plot_mvmax=[]

for x in xrange(len(mlats)):
   k = 1
   temp_mpres=[]
   temp_mvmax=[]
   for j in range(len(date_list)):
      for i in range(len(mpres[x])):
         if mtimes[x][i] == date_list[j]:
            temp_mpres.append(mpres[x][i])
            temp_mvmax.append(mvmax[x][i])

      if len(temp_mpres) < k: 
         temp_mpres.append(np.nan)  
         temp_mvmax.append(np.nan)  

      k += 1

   plot_mpres.append(temp_mpres)
   plot_mvmax.append(temp_mvmax)

#print len(date_list), len(plot_opres)






def plot_tracks(domain):

#  domain = 'Hawaii'
   print 'plotting '+cycle+' '+TC_name+' on '+domain+' domain'

   # create figure and axes instances
   if str.upper(domain) == 'CONUS':
    # fig = plt.figure(figsize=(6.9,4.9))
      fig = plt.figure(figsize=(10.9,8.9))
   elif domain == 'SRxSE':
      fig = plt.figure(figsize=(6.9,4.75))
   else:
      fig = plt.figure(figsize=(8,8))
   #  fig = plt.figure(figsize=(11,11))
   ax = fig.add_axes([0.1,0.1,0.8,0.8])



   if str.upper(domain) == 'CONUS':
      m = Basemap(llcrnrlon=-121.5,llcrnrlat=22.,urcrnrlon=-64.5,urcrnrlat=48.,\
                  resolution='i',projection='lcc',\
                  lat_1=32.,lat_2=46.,lon_0=-101.,area_thresh=1000.,ax=ax)

   elif domain == 'eCONUS':
      m = Basemap(llcrnrlon=-105.,llcrnrlat=22.,urcrnrlon=-64.5,urcrnrlat=48.,\
                  resolution='i',projection='lcc',\
                  lat_1=32.,lat_2=46.,lon_0=-95.,area_thresh=1000.,ax=ax)

   elif domain == 'eCONUSxE':
      m = Basemap(llcrnrlon=-100.,llcrnrlat=24.,urcrnrlon=-55,urcrnrlat=50.,\
                  resolution='i',projection='lcc',\
                  lat_1=32.,lat_2=46.,lon_0=-87.,area_thresh=1000.,ax=ax)

   elif domain == 'CONUSxE':
      m = Basemap(llcrnrlon=-121.5,llcrnrlat=22.,urcrnrlon=-50,urcrnrlat=55.,\
                  resolution='i',projection='lcc',\
                  lat_1=30.,lat_2=48.,lon_0=-95.,area_thresh=1000.,ax=ax)

   elif str.upper(domain) == 'SE':
      m = Basemap(llcrnrlon=-95.,llcrnrlat=24.5,urcrnrlon=-75.,urcrnrlat=40.,\
                  resolution='i',projection='lcc',\
                  lat_1=25.,lat_2=46.,lon_0=-87.,area_thresh=1000.,ax=ax)

   elif str.upper(domain) == 'MICHAEL':
      draw_counties=False
      m = Basemap(llcrnrlon=-90.,llcrnrlat=12.5,urcrnrlon=-70.,urcrnrlat=40.,\
                  resolution='i',projection='lcc',\
                  lat_1=25.,lat_2=46.,lon_0=-85.,area_thresh=1000.,ax=ax)

   elif domain == 'SRxSE':
      m = Basemap(llcrnrlon=-105,llcrnrlat=22,urcrnrlon=-70,urcrnrlat=40.,\
                  resolution='i',projection='lcc',\
                  lat_1=25.,lat_2=46.,lon_0=-90.,area_thresh=1000.,ax=ax)

   elif domain == 'MIDATLxNE':
      m = Basemap(llcrnrlon=-85,llcrnrlat=35.,urcrnrlon=-65,urcrnrlat=48.,\
                  resolution='i',projection='lcc',\
                  lat_1=25.,lat_2=46.,lon_0=-77.5,area_thresh=1000.,ax=ax)

   elif str.upper(domain) == 'MIDATL':
      m = Basemap(llcrnrlon=-90.,llcrnrlat=32.5,urcrnrlon=-70.,urcrnrlat=45.,\
                  resolution='i',projection='lcc',\
                  lat_1=25.,lat_2=46.,lon_0=-82.5,area_thresh=1000.,ax=ax)

   elif str.upper(domain) == 'FLORENCE':
      m = Basemap(llcrnrlon=-85.,llcrnrlat=31.,urcrnrlon=-70.,urcrnrlat=40.,\
                  resolution='i',projection='lcc',\
                  lat_1=25.,lat_2=46.,lon_0=-77.5,area_thresh=1000.,ax=ax)

   elif str.upper(domain) == 'MIDSOUTH':
      m = Basemap(llcrnrlon=-97.5,llcrnrlat=30.,urcrnrlon=-80.,urcrnrlat=42.5,\
    # m = Basemap(llcrnrlon=-100.,llcrnrlat=27.5,urcrnrlon=-75.,urcrnrlat=42.5,\    # wider view
                  resolution='i',projection='lcc',\
                  lat_1=25.,lat_2=46.,lon_0=-92.5,area_thresh=1000.,ax=ax)

   elif str.upper(domain) == 'CPL':
    # m = Basemap(llcrnrlon=-105.,llcrnrlat=32.5,urcrnrlon=-87.5,urcrnrlat=45.,\
      m = Basemap(llcrnrlon=-105.,llcrnrlat=30.,urcrnrlon=-87.5,urcrnrlat=42.5,\
                  resolution='i',projection='lcc',\
                  lat_1=25.,lat_2=46.,lon_0=-97.5,area_thresh=1000.,ax=ax)

   elif str.upper(domain) == 'NW_ATL':
      draw_counties = False
      m = Basemap(llcrnrlon=-90.,llcrnrlat=24.,urcrnrlon=-50.,urcrnrlat=52.,\
                  resolution='i',projection='lcc',\
                  lat_1=32.,lat_2=46.,lon_0=-87.,area_thresh=1000.,ax=ax)

   elif str.upper(domain) == 'SE_COAST':
      draw_counties = False
      m = Basemap(llcrnrlon=-90.,llcrnrlat=24.,urcrnrlon=-62.5,urcrnrlat=42.,\
                  resolution='i',projection='lcc',\
                  lat_1=32.,lat_2=46.,lon_0=-80.,area_thresh=1000.,ax=ax)

   elif str.upper(domain) == 'NATL':
      draw_counties = False
      m = Basemap(llcrnrlon=-90.,llcrnrlat=10.,urcrnrlon=-15.,urcrnrlat=52.5,\
                  resolution='i',projection='merc',\
                  lat_ts=20.,area_thresh=1000.,ax=ax)

   elif str.upper(domain) == 'CPAC':
      draw_counties = False
      m = Basemap(llcrnrlon=-180.,llcrnrlat=5.,urcrnrlon=-110.,urcrnrlat=40.,\
                  resolution='i',projection='merc',\
                  lat_ts=20.,area_thresh=1000.,ax=ax)

   elif str.upper(domain) == 'HAWAII':
      draw_counties = False
      m = Basemap(llcrnrlon=-165.,llcrnrlat=10.,urcrnrlon=-145.,urcrnrlat=25.,\
                  resolution='i',projection='merc',\
                  lat_ts=20.,area_thresh=1000.,ax=ax)


   m.drawcoastlines()
   m.drawmapboundary(fill_color='#5c5c5c')
   m.fillcontinents(color='#D3D3D3',lake_color='#5c5c5c',zorder=0)
#  m.fillcontinents(color='#D4D4D4',zorder=0)
   latlongrid = 10.
   if draw_counties:
      m.drawcounties()
      latlongrid = 5.
   m.drawstates(linewidth=0.25)
   m.drawcountries()
   parallels = np.arange(0.,90.,latlongrid)
   m.drawparallels(parallels,labels=[1,0,0,0],fontsize=10)
   meridians = np.arange(180.,360.,latlongrid)
   m.drawmeridians(meridians,labels=[0,0,0,1],fontsize=10)

#  print np.shape(olat)
   cmap=matplotlib.cm.get_cmap('YlGnBu')

   for i in xrange(len(mlats)):
   #  label_str = mtimes[i][0].strftime('%HZ %m/%d')
      x, y = m(mlons[i],mlats[i])
   #  m.plot(x, y, '-', color=cmap(float(i+1)/float(len(mlats)+1)), label=label_str, linewidth=2.)
      m.plot(x, y, '-', color=cmap(float(i+1)/float(len(mlats)+1)), linewidth=2.)

   x, y = m(olon,olat)
   m.plot(x, y, '-', color='black', label='BEST', linewidth=2.)

#  plt.legend(loc="upper right")

   titlestr1 = 'Hurricane '+TC_name+' - '+str.upper(model)+' Tracks'
   titlestr2 = mtimes[0][0].strftime('%HZ %d %b')+' to '+mtimes[-1][0].strftime('%HZ %d %b %Y Initializations')
   plt.text(0.5, 1.05, titlestr1, horizontalalignment='center', transform=ax.transAxes)
   plt.text(0.5, 1.01, titlestr2, horizontalalignment='center', transform=ax.transAxes)

   fname = str.lower(TC_name)+'_'+str.lower(model_str)+'_tracks_'+str.lower(domain)

   plt.savefig(OUT_DIR+'/'+fname+'.png',bbox_inches='tight')
   plt.close()






def plot_ptrace():

   print 'plotting pressure traces'
   print len(plot_opres)    # same length as date_list

   fig = plt.figure(figsize=(9,8))
   cmap=matplotlib.cm.get_cmap('YlGnBu')

   for i in xrange(len(plot_mpres)):
#     label_str = mtimes[i][0].strftime('%HZ %m/%d')
#     plt.plot(plot_mpres[i], '-', color=cmap(float(i+1)/float(len(plot_mpres)+1)), label=label_str, linewidth=2.)
      plt.plot(plot_mpres[i], '-', color=cmap(float(i+1)/float(len(plot_mpres)+1)), linewidth=2.)

   plt.plot(plot_opres, '-', color='black', label='BEST', linewidth=2.)


   xlen = len(plot_opres) 
   x = np.arange(0,xlen,1)


   plt.axis([0,xlen,900,1020])
   plt.axhspan(900, 1020, facecolor='0.5', alpha=0.5)

   labels=[]
   for x in xrange(0,xlen,2):
      if x%6 == 0:
         labels.append(date_list[x].strftime('%HZ %m/%d'))
      else:
         labels.append('')

#  labels = [date_list[x].strftime('%HZ %m/%d') for x in range(0,xlen,6)]
   plt.xticks(np.arange(0,xlen,step=2),labels,rotation=-45,ha='left')
   plt.ylabel('Minimum Pressure (mb)')

   plt.grid(True)

   titlestr = 'Hurricane '+TC_name+' - '+str.upper(model)+' Minimum Pressure Traces \n'+ \
              mtimes[0][0].strftime('%HZ %d %b')+' to '+mtimes[-1][0].strftime('%HZ %d %b %Y Initializations')
   plt.title(titlestr)

   fname = str.lower(TC_name)+'_'+str.lower(model_str)+'_ptrace'

   plt.savefig(OUT_DIR+'/'+fname+'.png',bbox_inches='tight')
   plt.close()




def plot_vmaxtrace():

   print 'plotting wind traces'
   print len(plot_ovmax)    # same length as date_list

   fig = plt.figure(figsize=(9,8))
   cmap=matplotlib.cm.get_cmap('YlGnBu')

   for i in xrange(len(plot_mvmax)):
    # label_str = mtimes[i][0].strftime('%HZ %m/%d')
    # plt.plot(plot_mvmax[i], '-', color=cmap(float(i+1)/float(len(plot_mvmax)+1)), label=label_str, linewidth=2.)
      plt.plot(plot_mvmax[i], '-', color=cmap(float(i+1)/float(len(plot_mvmax)+1)), linewidth=2.)

   plt.plot(plot_ovmax, '-', color='black', label='BEST', linewidth=2.)


   xlen = len(plot_ovmax) 
   x = np.arange(0,xlen,1)

   plt.axis([0,xlen,20,150])
   plt.axhspan(0, 34, facecolor='0.5', alpha=0.5)
   plt.axhspan(34, 64, facecolor='0.4', alpha=0.5)
   plt.axhspan(64, 83, facecolor='0.3', alpha=0.5)
   plt.axhspan(83, 96, facecolor='0.25', alpha=0.5)
   plt.axhspan(96, 113, facecolor='0.2', alpha=0.5)
   plt.axhspan(113, 137, facecolor='0.15', alpha=0.5)
   plt.axhspan(137, 200, facecolor='0.1', alpha=0.5)

   labels=[]
   for x in xrange(0,xlen,2):
      if x%6 == 0:
         labels.append(date_list[x].strftime('%HZ %m/%d'))
      else:
         labels.append('')

#  labels = [date_list[x].strftime('%HZ %m/%d') for x in range(0,xlen,6)]
   plt.xticks(np.arange(0,xlen,step=2),labels,rotation=-45,ha='left')
   plt.ylabel('Maximum Sustained 10-m Wind (kts)')

#  plt.annotate('Cat 1',xy=(xlen+1,73.5))

   plt.grid(True)

   titlestr = 'Hurricane '+TC_name+' - '+str.upper(model)+' Max 10-m Wind Traces \n'+ \
              mtimes[0][0].strftime('%HZ %d %b')+' to '+mtimes[-1][0].strftime('%HZ %d %b %Y Initializations')
   plt.title(titlestr)

   fname = str.lower(TC_name)+'_'+str.lower(model_str)+'_vmaxtrace'

   plt.savefig(OUT_DIR+'/'+fname+'.png',bbox_inches='tight')
   plt.close()




plot_ptrace()
plot_vmaxtrace()
plot_tracks(domain = 'Michael')



