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

model = "fv3gfstest"
;model = "gfs"

type = "emsl"
ECname = "centralUS"
dir_out = "/meso/save/Alicia.Bentley/MEG/snow/"
dir_data = "/meso/save/Alicia.Bentley/MEG/snow/data/"
dir_out_web = "/home/people/emc/www/htdocs/users/Alicia.Bentley/test/check/"

syyyy = 2019
smm = 4
sdd = 10
shh = 0

eyyyy = 2019
emm = 4
edd = 13
ehh = 0

fcst_hr_change = 12       ; was 24

fyyyy = 2019
fmm = 4
fdd = 6
fhh = 0

lyyyy = 2019
lmm = 4
ldd = 7
lhh = 0

rad_search = 400.0

lat_change =  1.0
lon_change =  1.5

make_maps = "on"
;make_maps = "off"

; ********************************************************
; Set up file names and arrays and things for output
; ********************************************************
textfilename = model+"_fcst_"+type+"_"+ECname+".csv"
timeUnits = "hours since 1800-01-01 00:00:00"
;system("rm "+dir_out+textfilename)

sdate = cd_inv_calendar(syyyy,smm,sdd,shh,00,00,timeUnits,0)
edate = cd_inv_calendar(eyyyy,emm,edd,ehh,00,00,timeUnits,0)
timesteps = toint(((edate-sdate)/6.)+1)
hours = toint(edate-sdate)
print("sdate: "+sdate+" | edate: "+edate+" | timesteps: "+timesteps+" | hours: "+hours)

fdate = cd_inv_calendar(fyyyy,fmm,fdd,fhh,00,00,timeUnits,0)
ldate = cd_inv_calendar(lyyyy,lmm,ldd,lhh,00,00,timeUnits,0)
cycles = toint(((ldate-fdate)/fcst_hr_change)+1)
print("fdate: "+fdate+" | ldate: "+ldate+" | cycles: "+cycles)

track_arr := new((/cycles,timesteps,10/),double,-999999)
track_arr!0 = "cycle"
track_arr!1 = "timesteps"
track_arr!2 = "yyyy/mm/dd/hh/lat/lon/mslp/mslp_error/dist_error/forecast_number"
;printVarSummary(track_arr)

outlines := new((/cycles*timesteps/),"string")

count = -1
change_guess = 0

;*********************************************************

; Read in file with gfs analysis tracks

track_url = "./"
trk_read = asciiread(track_url+"gfs_anl_"+type+"_"+ECname+".csv",-1,"string")
delim = ", "
nfields = str_fields_count(trk_read, delim)
;print("nfields: "+nfields)

print("Obtaining data from file of unknown length...")

yyyy_arr_temp := str_get_field(trk_read, 1, delim)
mm_arr_temp := str_get_field(trk_read, 2, delim)
dd_arr_temp := str_get_field(trk_read, 3, delim)
hh_arr_temp := str_get_field(trk_read, 4, delim)
mslp_arr_temp := str_get_field(trk_read, 5, delim)
rlat_arr_temp := str_get_field(trk_read, 6, delim)
rlon_arr_temp := str_get_field(trk_read, 7, delim)
cyc_arr_temp := str_get_field(trk_read, 8, delim)

;printVarSummary(yyyy_arr_temp)

iz = ind(yyyy_arr_temp .eq. syyyy)
print(iz)

yyyy_arr := todouble(yyyy_arr_temp(iz))
mm_arr := todouble(mm_arr_temp(iz))
dd_arr := todouble(dd_arr_temp(iz))
hh_arr := todouble(hh_arr_temp(iz))
mslp_arr := todouble(mslp_arr_temp(iz))
rlat_arr := todouble(rlat_arr_temp(iz))
rlon_arr := todouble(rlon_arr_temp(iz))
cyc_arr := todouble(cyc_arr_temp(iz))

print(" ")
print("GFS analysis positions successfully collected from file!")

; *********************************************************
; Obtain GFS analysis data to get "best track" positions 
; *********************************************************

do curdate = fdate,ldate,fcst_hr_change
;	print("curdate: "+curdate)
	count = count + 1

	cyear = cd_string(curdate,"%Y")
	cmon = cd_string(curdate,"%N")
	cday = cd_string(curdate,"%D")
	chr = cd_string(curdate,"%H")
	now = cyear+cmon+cday
	print("now: "+now+" "+chr)

	; Find forecast hours by taking different between in
	int_diff = toint(sdate-curdate)
	print("int_diff: "+int_diff)

	sfhr = int_diff
	efhr = int_diff + hours
	print("sfhr: "+sfhr+" | efhr: "+efhr)

	spot = -1

do hr = sfhr,efhr,6
	spot = spot + 1

	if hr .lt. 10. then
		fhr := "00"+hr
	end if
	if (hr .ge. 10.) .and. (hr .lt. 100.) then
		fhr := "0"+hr
	end if
	if (hr .ge. 100) then
		fhr := hr
	end if
print(" ")	
print("fhr: "+fhr)
	
	fcst_file = addfile(dir_data+model+"."+now+".t"+chr+"z.pgrb2.0p25.f"+fhr+".grib2","r")

if type .eq. "pmsl" then
        mslp_anl := fcst_file->PRMSL_P0_L101_GLL0(::-1,:)
	mslp_anl = mslp_anl/100.
end if

if type .eq. "emsl" then
       	mslp_anl_temp := fcst_file->MSLET_P0_L101_GLL0(::-1,:)
       	mslp_anl_temp = mslp_anl_temp/100.
	mslp_anl = mslp_anl_temp
	do d=0,1
    		mslp_anl=smth9(mslp_anl,.5,.25,True)
  	end do
end if

;       printVarSummary(mslp_anl)
;	printMinMax(mslp_anl,True)

        mslp_anl_circ := mslp_anl

	if hr .eq. sfhr then
		print("***************************************************************************************")
        	print("Guessing lat/lon at first fhr using track at index "+spot+"!")
	        guess_elat = tofloat(rlat_arr(spot))
        	guess_elon = tofloat(rlon_arr(spot))
	else
        	print("Guessing lat/lon at previous time!")
        	guess_elat = tofloat(guess_elat + lat_change)        ;3.
        	guess_elon = tofloat(guess_elon + lon_change)       ;4.5
	end if

	print("guessing lat: "+guess_elat+" | guessing lon: "+guess_elon)
	print(" ")

;------------------------------------------

	;rad_search = 500.0        ;700.0

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
	printMinMax(mslp_anl_circ,True)
;	printVarSummary(mslp_anl_circ)


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
;   		print(array2check)

   		qsort(new_values)
;		print(new_values)
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
    					print("found_circ_arr(b): "+decimalPlaces(found_circ_arr(b),2,True)+" found_lat_arr(b): "+found_lat_arr(b)+" found_lon_arr(b): "+(found_lon_arr(b)-360.))
    				end if	; if too close or too weak
    			else
    				print("found_circ_arr(b): "+decimalPlaces(found_circ_arr(b),2,True)+" found_lat_arr(b): "+found_lat_arr(b)+" found_lon_arr(b): "+(found_lon_arr(b)-360.))
    			end if ; b .gt. 0
    		end do
    					
    		notmissing := ind(.not.ismissing(found_circ_arr))
;    		print(found_circ_arr)	

	end if ; locmin .ne. 0

  		dims = dimsizes(mslp_anl_circ)
  		x1d = ndtooned(mslp_anl_circ)      ; convert 2D array to 1D for use in minind
  		inds = ind_resolve(minind (x1d), dims)    ; convert 1D array back to 2D 
  		ilat = inds(0,0)        ; select the latitude index where the X array is at its' minimum  
  		ilon = inds(0,1)        ; select the longitude index where the X array is at its' minimum  
  		lat_min = mslp_anl_circ&lat_0(ilat)   ; insert the latitude index into the lat coord
  		lon_min = mslp_anl_circ&lon_0(ilon)   ; insert the longitude index into the lon coord
  		print("Min. ("+mslp_anl_circ({lat_min},{lon_min})+"hPa) located at "+lat_min+", "+(lon_min-360.)) 
		

if (locmin .ne. 0) then

	print(mslp_anl_circ({lat_min},{lon_min}))
	print((/found_circ_arr(0)/))	

	if (mslp_anl_circ({lat_min},{lon_min})) .lt. (/found_circ_arr(0)/) then
		found_circ_arr = mslp_anl_circ({lat_min},{lon_min})
                found_lat_arr = lat_min
       		found_lon_arr = lon_min
	end if
else
                print("NO LOCAL MINIMUM FOUND!!!!!!!!")
                print("PUT IN THE LOCATION OF THE MINUMUM VALUE!!!!!!!!")
                change_guess = 1

	        found_circ_arr = mslp_anl_circ({lat_min},{lon_min})
                found_lat_arr = lat_min
                found_lon_arr = lon_min

		if type .eq. "emsl" then
			found_circ_arr = mslp_anl_temp({lat_min},{lon_min})
		end if
end if


;-------------------------------------------------------------------------------

print("count: "+count)
print("spot: "+spot)

track_arr(count,spot,0) = todouble(cyear)
track_arr(count,spot,1) = todouble(cmon)
track_arr(count,spot,2) = todouble(cday)
track_arr(count,spot,3) = todouble(chr)
track_arr(count,spot,4) = (/found_circ_arr(0)/)
track_arr(count,spot,5) = (/found_lat_arr(0)/)
track_arr(count,spot,6) = (/found_lon_arr(0)-360/) 

if type .eq. "emsl" then
	track_arr(count,spot,4) = mslp_anl_temp({found_lat_arr(0)},{found_lon_arr(0)})
end if


;print(track_arr(count,spot,4:6))	 

if (change_guess .eq. 0) then
	guess_elat := tofloat(found_lat_arr(0)) 
	guess_elon := tofloat(found_lon_arr(0))
end if
if (change_guess .eq. 1) then
        guess_elat := tofloat(found_lat_arr(0)) 		; tofloat(rlat_arr(spot))
        guess_elon := tofloat(found_lon_arr(0))			; tofloat(rlon_arr(spot))
	change_guess = 0
end if


bpres = mslp_arr(spot)
blat = rlat_arr(spot)
blon = 360.+rlon_arr(spot)

cpres := (found_circ_arr(0))
clat := (found_lat_arr(0))
clon := (found_lon_arr(0)) 

print("cres:  "+cpres+" clat: "+clat+" clon: "+clon+" (Forecast Values)")
print("bpres: "+bpres+" blat: "+blat+" blon: "+blon+" (Analysis Values)")

        pres_error = cpres-bpres
        dist_error = gc_latlon(clat,clon, blat,blon, 10,4)
        if (blat .eq. clat) .and. (blon .eq. clon) then
                dist_error = 0.0
        end if

track_arr(count,spot,7) = tofloat(pres_error)
track_arr(count,spot,8) = tofloat(dist_error)







;******************************************************************************************
;******************************************************************************************
;******************************************************************************************

if make_maps .eq. "on" then

        minlat = 24.
        maxlat = 55.
        minlon = -83.
        maxlon = -54.

minlat = 0.
maxlat = 55.
minlon = -115.
maxlon = -30.

        name = model+"_"+ECname+"_"+now+chr+"_"+fhr
        dir_out = "./"

;==============================================
; Create Shaded Map
;==============================================
wks_type = "png"

wks_type@wkWidth = 2500
wks_type@wkHeight = 2500

wks = gsn_open_wks(wks_type,name)
gsn_define_colormap(wks,"GMT_haxby")          ; "NCV_jet")
;colors = (/97,96,95,94,93,92,91,90,89,88,87,79,78,77,76,75,74,73,72,71,70,67,66,65,64,63,62,61,60,59,58,51,50,49,48,47,46,45,44,43,42,33,32,31,30,29,28,27,26,25,24,21,20,19,18,17,16,15,14,13,12,11/)


;**********************************************

res = True

res@gsnFrame = False                                             ;DO NOT PLOT FIRST MAP
res@gsnDraw = False

res@tiMainString = " "    ; Specify Title
res@tiMainJust = "CenterCenter"
res@tiMainPosition = "Center"
res@tiMainOffsetYF = -0.03
res@tiXAxisFontHeightF = .015
res@gsnLeftString = " "
res@gsnLeftStringOrthogonalPosF = .014
res@gsnRightString =" "
res@gsnRightStringOrthogonalPosF = .011
res@gsnStringFontHeightF = .013

res@mpFillOn = True
res@mpLandFillColor = "gray75"  ;"grey75"
;res@mpInlandWaterFillColor = "lightsteelblue2"
;res@mpOceanFillColor = "lightsteelblue2"
res@mpInlandWaterFillColor = "white"
res@mpOceanFillColor = "white"
res@mpDataBaseVersion = "MediumRes"                              ; Country Outlines
res@mpDataSetName = "Earth..4"
res@mpOutlineBoundarySets = "National"
res@mpOutlineSpecifiers = (/"Canada : Provinces","United States : States"/)
res@mpOutlineOn = True
res@mpGeophysicalLineColor = "grey12"
res@mpNationalLineColor = res@mpGeophysicalLineColor
res@mpUSStateLineColor = res@mpGeophysicalLineColor
res@mpGeophysicalLineThicknessF = 4
res@mpNationalLineThicknessF = 3
res@mpUSStateLineThicknessF = 3

res@cnFillOn = True
res@cnFillMode = "AreaFill"
res@cnRasterSmoothingOn = True
res@cnLabelMasking = True
res@cnLevelSelectionMode = "ManualLevels"
res@cnLinesOn = True                               ; Turn off contour lines
res@cnLineLabelsOn = True
res@cnLevelSpacingF = 1
res@cnMinLevelValF = 960
res@cnMaxLevelValF = 1040
;res@cnFillColors = colors
res@cnLineLabelInterval = 1
res@cnLineLabelAngleF = 0.0
res@cnLineLabelInterval := 0.5
res@cnLineLabelDensityF = 2.4
;mres@cnSmoothingOn = True
;mres@cnSmoothingDistanceF = 0.009
res@cnLineLabelBackgroundColor = -1
res@cnLineLabelFontHeightF = 0.008
res@gsnAddCyclic =  True

res@lbLabelBarOn = False
res@lbAutoManage = False                   ; Label Bar Information
res@pmLabelBarOrthogonalPosF = .02
res@pmLabelBarHeightF = 0.08
res@pmLabelBarWidthF = 0.41
res@lbLabelAutoStride = False
res@lbLabelFontHeightF = .011
res@lbBoxLinesOn  = True                   ; Outline the color bar
res@lbTopMarginF = .3
res@cnInfoLabelOn = False
res@lbLabelStride = 1
res@lbLabelFontColor = "black"
res@cnExplicitLabelBarLabelsOn = True

res@mpGridAndLimbOn        = True
res@mpGridLineDashPattern  = 5                  ; lat/lon lines dashed
res@mpGridLatSpacingF      = 10
res@mpGridLonSpacingF      = 10
res@mpGridLineColor = "grey25"
res@mpGridLineThicknessF = 3


;---------------------------------------------------

res@mpProjection = "CylindricalEquidistant"
res@mpMinLatF = minlat
res@mpMaxLatF = maxlat
res@mpMinLonF = minlon
res@mpMaxLonF = maxlon

res@pmTickMarkDisplayMode = "Always"

res@tmYROn = False
res@tmXTOn = False

res@gsnLeftString = "Forecasts initialized "+now+chr+" Fhr: "+fhr  
res@gsnLeftStringOrthogonalPosF = .0075
res@gsnLeftStringFontHeightF = .008
res@gsnRightString = "Model: "+model
res@gsnRightStringOrthogonalPosF = .0075
res@gsnRightStringFontHeightF = .008

; *************************************************************

cres = True

cres@gsnFrame = False
cres@gsnDraw = False

cres@gsnLeftString = " "
cres@gsnRightString = " "

cres@cnInfoLabelOn = False                    ; Removes descriptive box in lower right corner
cres@cnFillOn = False
cres@cnLineLabelsOn = False
cres@cnLinesOn = True
cres@cnLabelMasking = True
cres@cnLineThicknessF = 10                    ; Changes thickness of contours
cres@cnLevelSelectionMode = "ExplicitLevels"
cres@cnLevels = (/1.99/)
cres@cnLineLabelAngleF = 0.0
;cres@cnLineLabelInterval = 2
cres@cnLineLabelDensityF = 1.4
;cres@cnSmoothingOn = True
;cres@cnSmoothingDistanceF = 0.009
cres@cnLineLabelBackgroundColor = -1
cres@cnLineLabelFontHeightF = 0.008
cres@gsnAddCyclic =  True

;*******************************************
res@mpFillOn = True
res@mpOutlineOn = True
;res@cnFillDrawOrder = "Draw"
;res@mpFillDrawOrder = "PreDraw"
;res@mpOutlineDrawOrder = "Draw"
;res@mpGridAndLimbDrawOrder = "PostDraw"

plot = gsn_csm_contour_map(wks, mslp_anl, res)
bloop = gsn_csm_contour(wks, circ_calc, cres)

overlay(plot,bloop)

;********************************************

draw(plot)
frame(wks)

;********************************************

system("convert -trim "+name+".png "+name+".png")

;********************************************


end if    ; make_maps

;************************************************************************
;************************************************************************
;************************************************************************





end do   ; end hr


if make_maps .eq. "on" then
system ("scp "+model+"_"+ECname+"*.png abentley@emcrzdm:"+dir_out_web+".")
end if


print(track_arr(count,:,4:6))
print(" ")

end do   ; end curdate

;-------------------------------------------------------------------------------
print(" ")
loc = -1

do i = 0,cycles-1,1
	do j = 0,timesteps-1,1

	loc = loc + 1

	line = track_arr(i,j,0)+", "+track_arr(i,j,1)+", "+track_arr(i,j,2)+", "+track_arr(i,j,3)+", "+track_arr(i,j,4)+", "+track_arr(i,j,5)+", "+track_arr(i,j,6)+", "+track_arr(i,j,7)+", "+track_arr(i,j,8)+", "+i
	print("line: "+line)
        outlines(loc) = line

	end do
print(" ")
end do

;asciiwrite(dir_out+textfilename, outlines)

;-------------------------------------------------------------------------------

track_arr(:,:,7) = abs(track_arr(:,:,7))

error_per_cycle = dim_avg_n_Wrap(track_arr,1)     ; (count,spot,8)
print(error_per_cycle(:,7:8))

error_per_model = dim_avg_n_Wrap(error_per_cycle,0)
print(error_per_model(7:8)) 

















print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end
