;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;load "~/ncl/lib/tTick.ncl"
;load "~/ncl/lib/ut_string.ncl"
;load "~/ncl/lib/latlon.ncl"
;load "~/ncl/lib/addbox.ncl"
;************************************************************************

begin

print(" ")
print("**************")
print(" START SCRIPT ")
print("**************")
print(" ")

name = "bomb_cyclone"
dir_out = "/meso/save/Alicia.Bentley/MEG/EC_tracks/"
dir_data = "/meso/save/Alicia.Bentley/MEG/EC_tracks/bomb_cyclone/"
dir_out_web = "/home/people/emc/www/htdocs/users/Alicia.Bentley/MEG/EC_tracks/"

syyyy = 2018
smm = 1
sdd = 3
shh = 18

eyyyy = 2018
emm = 1
edd = 6
ehh = 0

guess_elat = 50.
guess_elon = 360.-65. 

howmany_models = 2
howmany_fcsts = 6

fyyyy = 2017
fmm = 12
fdd = 28
fhh = 0

lyyyy = 2018
lmm = 1
ldd = 3
lhh = 0

;make_maps = "on"
make_maps = "off"

; ********************************************************
; Set up file names and arrays and things for output
; ********************************************************
textfilename = "gfs_anl_"+name+".csv"
timeUnits = "hours since 1800-01-01 00:00:00"
system("rm "+dir_out+textfilename)

sdate = cd_inv_calendar(syyyy,smm,sdd,shh,00,00,timeUnits,0)
edate = cd_inv_calendar(eyyyy,emm,edd,ehh,00,00,timeUnits,0)
timesteps = toint(((edate-sdate)/6.)+1)
print("sdate: "+sdate+" | edate: "+edate+" | timesteps: "+timesteps)

fdate = cd_inv_calendar(fyyyy,fmm,fdd,fhh,00,00,timeUnits,0)
ldate = cd_inv_calendar(lyyyy,lmm,ldd,lhh,00,00,timeUnits,0)

track_arr := new((/timesteps,7/),double,-999999)
track_arr!0 = "timesteps"
track_arr!1 = "yyyy/mm/dd/hh/lat/lon/mslp"
;printVarSummary(track_arr)

outlines := new((/timesteps/),"string")

count = -1

; *********************************************************
; Obtain GFS analysis data to get "best track" positions 
; *********************************************************

do curdate = edate,sdate,6
;	print("curdate: "+curdate)
	count = count + 1

	cyear = cd_string(curdate,"%Y")
	cmon = cd_string(curdate,"%N")
	cday = cd_string(curdate,"%D")
	chr = cd_string(curdate,"%H")
	now = cyear+cmon+cday
	print("now: "+now+" "+chr)

	gfs_anl_file = addfile(dir_data+"gfs."+now+".t"+chr+"z.pgrb2.0p25.f000.grib2","r")

;	mslp_anl := gfs_anl_file->PRMSL_P0_L101_GLL0(::-1,:)                
	mslp_anl := gfs_anl_file->MSLET_P0_L101_GLL0(::-1,:)
	mslp_anl = mslp_anl/100.
;	printVarSummary(mslp_anl)

    	mslp_anl_circ := mslp_anl

if curdate .eq. edate then
	print("Guessing lat/lon at edate!")
else
	print("Guessing lat/lon at previous time!")
	guess_elat = guess_elat - 2. 
	guess_elon = guess_elon - 2.
end if

	print("guessing lat: "+guess_elat+" | guessing lon: "+guess_elon)
	print(" ")
;------------------------------------------

	rad_search = 1000.0

	intdist = toint(rad_search)

 	lat_tot := conform(mslp_anl,mslp_anl&lat_0,0)
	lon_tot := conform(mslp_anl,mslp_anl&lon_0,1)
	lat_tot@_FillValue := 9.969209968386869e+36
	lon_tot@_FillValue := 9.969209968386869e+36
	
    	lat_EWE := mslp_anl&lat_0 
    	lon_EWE := mslp_anl&lon_0 

    	lat_EWE = (/guess_elat/)
    	lon_EWE = (/guess_elon/)

    	r = 6370. ; radius of spherical Earth (km)    
    	d2r = 0.0174532925199433 ; degrees to radians conversion factor
       
    	lat1 := lat_tot
    	lon1 := lon_tot
    	lat2 := conform(mslp_anl,lat_EWE,0)
    	lon2 := conform(mslp_anl,lon_EWE,1)  
       
    	lat1 := lat1*d2r
    	lon1 := lon1*d2r  
    	lat2 := lat2*d2r
    	lon2 := lon2*d2r    
  
    	dlat := lat2-lat1
    	dlon := lon2-lon1
    	latTerm := sin(.5*dlat) 
        latTerm := latTerm*latTerm
    	lonTerm := sin(.5*dlon) 
    	lonTerm := lonTerm*lonTerm*cos(lat1)*cos(lat2)
    	dAngle := sqrt(latTerm+lonTerm)
    	dist := 2.*r*asin(dAngle)
    
;-----------------------------------------------------------------  
    
	circ_calc := where((dist .le. rad_search),2,0)
	copy_VarCoords(mslp_anl,circ_calc)

	mslp_anl_circ = where((circ_calc .eq. 2),mslp_anl_circ,mslp_anl_circ@_FillValue)

;-----------------------------------------------------------------

  	delta = 0.0
  	locmin := local_min(mslp_anl_circ,True,delta)
  	print(locmin)

  	if (locmin .ne. 0) then
;		print("Min values exist!")
  
  		lats = mslp_anl_circ&lat_0
  		lons = mslp_anl_circ&lon_0

  		xtemp := lats(locmin@yi)
  		ytemp := lons(locmin@xi)
  		valtemp := locmin@minval 
;  		print(valtemp)

		index := ind(valtemp .lt. 9999999999.)
		index@_FillValue = -2147483647
;		print("index: "+index)

		if (.not.ismissing(index(0))) then
			x := xtemp(index)
			y := ytemp(index)				
			values := valtemp(index)
		else
			print("Bad!")
			x := 1
			y := 1
			values := 9999999999.
		end if
;		print(values)

		array2check := values(:)
   		new_values := values(:)
   		print(array2check)

   		qsort(new_values)
		print(new_values)
		print(" ")
		
   		new_length = dimsizes(new_values)
   		found_circ_arr := new(new_length,double,0)
   		found_lat_arr := new(new_length,double,0)
   		found_lon_arr := new(new_length,double,0)
   						
   		found_circ_arr@_FillValue = 9999999999.0
   		found_lat_arr@_FillValue = 9999999999.0
    		found_lon_arr@_FillValue = 9999999999.0		
	
   		do b = 0,new_length-1	   				
			circ2check = new_values(b)
			print(" ")
			print("circ2check: "+circ2check)
			found := closest_val(circ2check,array2check)
    			print("found (at this orig. index): "+found)
    			found_circ_arr(b) = values(found)
    			found_lat_arr(b) = x(found)
    			found_lon_arr(b) = y(found)
    			print("values: "+values(found)+" lat: "+x(found)+" lon: "+(y(found)))    					

    			if b .gt. 0 then    								
    				notmissing := ind(.not.ismissing(found_circ_arr))
;    				print("notmissing: "+notmissing)
    				checkdist := new(dimsizes(notmissing)-1,double,0)

    				do c = 0,dimsizes(notmissing)-2
;    					print("notmissing(c): "+notmissing(c))
;    					print("found_lat_arr(notmissing(c)): "+found_lat_arr(notmissing(c))+" found_lon_arr(notmissing(c)): "+(found_lon_arr(notmissing(c))))
    					checkdist(c) = decimalPlaces(gc_latlon(x(found),y(found),found_lat_arr(notmissing(c)),found_lon_arr(notmissing(c)),20,-4),1,True)
;   					print("c: "+c+" checkdist(c): "+checkdist(c))
    				end do

    				min_dist = min(checkdist)
  				print("b: "+b+" min_dist: "+min_dist+ "values(found): "+values(found))

  				if (min_dist .lt. 1000) .or. (values(found) .gt. 1012.) then
    					print("NEXT LOW IS NOT CHOSEN B/C TOO CLOSE (<1000 km) or TOO WEAK (>1012 hPa)!")
    					found_circ_arr(b) = 9999999999.
    					found_lat_arr(b) = 9999999999.
    					found_lon_arr(b) = 9999999999.
    				else
    					print("GOOD POINT!")
    					print("found_circ_arr(b): "+decimalPlaces(found_circ_arr(b),2,True)+" found_lat_arr(b): "+found_lat_arr(b)+" found_lon_arr(b): "+(found_lon_arr(b)))
    				end if	; if too close or too weak
    			else
    				print("found_circ_arr(b): "+decimalPlaces(found_circ_arr(b),2,True)+" found_lat_arr(b): "+found_lat_arr(b)+" found_lon_arr(b): "+(found_lon_arr(b)))
    			end if ; b .gt. 0
    		end do
    					
    		notmissing := ind(.not.ismissing(found_circ_arr))
;    		print(found_circ_arr)	

	else

		print("LOST CYCLONE!")
		lat_max := 9999999999.  ; insert the latitude index into the lat coordinate variable
		lon_max := 9999999999.

	end if ;(locmin .ne. 0)

;-------------------------------------------------------------------------------

;print(count)

track_arr(timesteps-1-count,0) = todouble(cyear)
track_arr(timesteps-1-count,1) = todouble(cmon)
track_arr(timesteps-1-count,2) = todouble(cday)
track_arr(timesteps-1-count,3) = todouble(chr)
track_arr(timesteps-1-count,4) = (/found_circ_arr(0)/)
track_arr(timesteps-1-count,5) = (/found_lat_arr(0)/)
track_arr(timesteps-1-count,6) = (/found_lon_arr(0)-360/) 

;print(track_arr(timesteps-1-count,:))	 

end do

;print(track_arr(:,4:6))
print(" ")

;-------------------------------------------------------------------------------

do i = 0,timesteps-1

	line = track_arr(i,0)+", "+track_arr(i,1)+", "+track_arr(i,2)+", "+track_arr(i,3)+", "+track_arr(i,4)+", "+track_arr(i,5)+", "+track_arr(i,6)+", 0"
	print("line: "+line)
        outlines(i) = line

end do

asciiwrite(dir_out+textfilename, outlines)

;-------------------------------------------------------------------------------

print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end
