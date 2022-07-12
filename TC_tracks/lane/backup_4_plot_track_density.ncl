;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;;
;;
;; Plots track density of strong ECs leading to EWEs
;;
;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
;************************************************************************

begin

print(" ")
print("**************")
print(" START SCRIPT ")
print("**************")
print(" ")

; ********************************************************
; Specify center lat/lon to use in composite and variable
; ********************************************************
int_time = 2018082200
model = "gefs"
TCname = "lane"

dist = "150"

if model .eq. "gefs" then
	number = todouble(21)     ; number of members
end if
if model .eq. "ec" then
        number = todouble(50)     ; number of members
end if
if model .eq. "cmc" then
	number = todouble(21)
end if
if model .eq. "ukmet" then
	number = todouble(36)
end if 

name = model+"_track_density_"+int_time+"_"+TCname

dir_out = "./"
dir_out_web = "/home/people/emc/www/htdocs/users/Alicia.Bentley/fv3gfs/retros/images/lane/"
; scp *.png abentley@emcrzdm:/home/people/emc/www/htdocs/users/Alicia.Bentley/fv3gfs/retros/images/lane/.

fil = addfile(model+"_track_density_"+int_time+".nc","r")
count2 = fil->count(:,:)

count = todouble(count2 - 0)

count = (count/number)*100

do d=0,1
count=smth9(count,.5,.25,False)
end do

copy_VarCoords(count2,count)

printMinMax(count,True)

;==============================================
; Create Shaded Map
;==============================================
wks_type = "png"

wks_type@wkWidth = 2500
wks_type@wkHeight = 2500

wks = gsn_open_wks(wks_type,name)
gsn_define_colormap(wks,"MPL_rainbow")          ; "NCV_jet")
colors = gsn_retrieve_colormap(wks)  ; retrieve color map for editing. dimensioned (102,3)
;print(colors)

;colors(1,:) = (/ 1,1,1 /) ; replace the 32nd color
colors(8,:) = (/ 1,1,1 /)

;print(colors)

gsn_define_colormap(wks,colors)

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
res@mpGeophysicalLineThicknessF = 12
res@mpNationalLineThicknessF = 3
res@mpUSStateLineThicknessF = 3

res@cnFillOn = True   
res@cnFillMode = "AreaFill"
res@cnRasterSmoothingOn = True
res@cnLevelSelectionMode = "ManualLevels"
res@cnLinesOn = False                               ; Turn off contour lines
res@cnLevelSpacingF = 1
res@cnMinLevelValF = 1
res@cnMaxLevelValF = 99 
;res@cnLevels = (/1,5,10,15,20,30,40,50,60,70,80,90/)
;res@cnFillColors = colors
res@gsnSpreadColors = True
res@gsnSpreadColorStart = 8
res@gsnSpreadColorEnd = 128

res@lbAutoManage = False                   ; Label Bar Information
res@pmLabelBarOrthogonalPosF = .02  
res@pmLabelBarHeightF = 0.08
res@pmLabelBarWidthF = 0.7
res@lbLabelAutoStride = False
res@lbLabelFontHeightF = .011
res@lbBoxLinesOn  = True                   ; Outline the color bar 
res@lbTopMarginF = .3
res@cnInfoLabelOn = False 
res@lbLabelStride = 1 
res@lbLabelFontColor = "black"
res@cnExplicitLabelBarLabelsOn = True
res@lbLabelStrings = (/"1"," "," "," "," "," "," "," "," ","10"," "," "," "," "," "," "," "," "," ","20"," "," "," "," "," "," "," "," "," ","30"," "," "," "," "," "," "," "," "," ","40"," "," "," "," "," "," "," "," "," ","50"," "," "," "," "," "," "," "," "," ","60"," "," "," "," "," "," "," "," "," ","70"," "," "," "," "," "," "," "," "," ","80"," "," "," "," "," "," "," "," "," ","90"," "," "," "," "," "," "," "," ","99"/)

res@mpGridAndLimbOn        = True
res@mpGridLineDashPattern  = 5                  ; lat/lon lines dashed
res@mpGridLatSpacingF      = 20
res@mpGridLonSpacingF      = 20
res@mpGridLineColor = "grey25"
res@mpGridLineThicknessF = 3

;res@mpProjection = "CylindricalEquidistant"
;res@mpMinLatF = 5.
;res@mpMaxLatF = 60.
;res@mpMinLonF = -95.
;res@mpMaxLonF = -10.

res@mpProjection = "CylindricalEquidistant"
res@mpMinLatF = 0.
res@mpMaxLatF = 40.
res@mpMinLonF = 170.
res@mpMaxLonF = 260.

if int_time .eq. 2018090200 then
lat_adj = 2.
lon_adj = 0.
end if
if int_time .eq. 2018090300 then
lat_adj = 4.
lon_adj = 6.
end if
if int_time .eq. 2018090400 then
lat_adj = 6.
lon_adj = 8.
end if
if int_time .eq. 2018081800 then
lat_adj = -2.
lon_adj = 5.
end if
if int_time .eq. 2018081900 then
lat_adj = -1.
lon_adj = 3.
end if
if int_time .eq. 2018082000 then
lat_adj = 1.
lon_adj = 1.
end if
if int_time .ge. 2018082100 then
lat_adj = 2.
lon_adj = -3.
end if
if int_time .ge. 2018082200 then
lat_adj = 2.
lon_adj = -3.
end if


res@mpProjection = "CylindricalEquidistant"
res@mpMinLatF = 6.+lat_adj
res@mpMaxLatF = 35.+lat_adj
res@mpMinLonF = 179.+lon_adj
res@mpMaxLonF = 224.+lon_adj



res@tmXBOn = True
res@tmXBLabelsOn = True
res@tmXBMode = "Explicit" 
res@tmXBValues = ispan(160,260,20)
res@tmXBLabels = (/"160~F34~0~F~W","180~F34~0","160~F34~0~F~E","140~F34~0~F~E","120~F34~0~F~E","100~F34~0~F~E"/)
res@tmXBLabelFontHeightF = .011
res@tmXBMajorLengthF = .01
;res@tmXBMinorLengthF = .006
;res@tmXBMinorValues = (/-115.0,-105.0,-95.0,-85.0,-75.0,-65.0,-55.0,-45.0,-35.0/)

res@tmYLOn = True
res@tmYLLabelsOn = True
res@tmYLMode = "Explicit" 
res@tmYLValues = ispan(20,80,20)
res@tmYLLabels = (/"20~F34~0~F~N","40~F34~0~F~N","60~F34~0~F~N","80~F34~0~F~N"/)
res@tmYLLabelFontHeightF = .011
;res@tmYLMinorValues = (/32.5,37.5,42.5,47.5,52.5,57.5/)

res@tmYROn = False
res@tmXTOn = False

res@gsnLeftString = "Initialized:  "+int_time
res@gsnLeftStringOrthogonalPosF = .0075 
res@gsnLeftStringFontHeightF = .008
res@gsnRightString = "Probability (%) that TC center passes within "+dist+" km"
res@gsnRightStringOrthogonalPosF = .0075
res@gsnRightStringFontHeightF = .008


;********************************************
res@mpFillOn = True
res@mpOutlineOn = True
res@cnFillDrawOrder = "PreDraw"
res@mpFillDrawOrder = "PreDraw"
res@mpOutlineDrawOrder = "Draw"
res@mpGridAndLimbDrawOrder = "PostDraw"

plot = gsn_csm_contour_map(wks, count, res) 

;************************************************************************
;************************************************************************
;************************************************************************
;************************************************************************

; Read in file with cyclone tracks

track_url = "./"
trk_read = asciiread(track_url+model+"_"+int_time+"_"+TCname+".csv",-1,"string")
delim = ", "
nfields = str_fields_count(trk_read, delim)
;print("nfields: "+nfields)

print("Obtaining data from file of unknown length...")

yyyy_arr_temp = str_get_field(trk_read, 1, delim)
mm_arr_temp = str_get_field(trk_read, 2, delim)
dd_arr_temp = str_get_field(trk_read, 3, delim)
hh_arr_temp = str_get_field(trk_read, 4, delim)
mslp_arr_temp = str_get_field(trk_read, 5, delim)
rlat_arr_temp = str_get_field(trk_read, 6, delim)
rlon_arr_temp = str_get_field(trk_read, 7, delim)
wind_arr_temp = str_get_field(trk_read, 8,delim)
cyc_arr_temp = str_get_field(trk_read, 9,delim)

;printVarSummary(yyyy_arr_temp)

iz = ind(yyyy_arr_temp .eq. 2018)
;print(iz)

rlat_arr = todouble(rlat_arr_temp(iz))
rlon_arr = todouble(rlon_arr_temp(iz))
cyc_arr = todouble(cyc_arr_temp(iz))

print(cyc_arr)

;************************************************************************

tkres = True
tkres@gsLineColor = "white"
tkres@gsLineThicknessF = 3

length = doubletoint(dimsizes(cyc_arr))
line3 = new(length,graphic)

l_lat := new(length,double,0)
l_lon := new(length,double,0)
previous_cyc = todouble(-1)

start_position = 0
spot = 0
cyc_num = 1

;printVarSummary(cyc_arr)

;***********************************************************

startpoint = 0
toolong = 0

endvar = dimsizes(cyc_arr)-1

do i = 1,endvar
  previous2_cyc = todouble(-2)
  previous_cyc = cyc_arr(i-1)
  current_cyc = cyc_arr(i)
  l_lat(i-1) = rlat_arr(i-1)
  l_lon(i-1) = rlon_arr(i-1)
  l_lat(i) = rlat_arr(i)
  l_lon(i) = rlon_arr(i)
  
	if (current_cyc .ne. previous_cyc) .or. (i .eq. endvar) then
		print(" ")
   		print("******Starting cyclone "+previous_cyc+"******")
   		cyc_num = cyc_num + 1
   		if i .eq. endvar then
   			endpoint = i-1
   		else
   		    endpoint = i-2
   		end if
   		
   		print("startpoint: "+startpoint)
   		print("endpoint: "+endpoint)

  		do h = startpoint,endpoint
  	  		spot = spot + 1
;  			print("Line Drawn: "+spot)
  			l_lat_plot := (/l_lat(h),l_lat(h+1)/)
    		l_lon_plot := (/l_lon(h),l_lon(h+1)/)
;    		print("last lat: "+l_lat(h+1))
    		
			line3(spot-1) = gsn_add_polyline(wks,plot,l_lon_plot,l_lat_plot,tkres)
			
		end do ; end h
		
		startpoint = i
	end if
	
	previous_cyc = cyc_arr(i)
	previous2_cyc = cyc_arr(i-1)
end do  ; end plot tracks 

;************************************************************************
;************************************************************************
;************************************************************************
;************************************************************************

; Read in file with cyclone tracks
if model .eq. "gefs" then
	lines_m = 72 
end if
if model .eq. "ec" then
	lines_m = 81
end if
if model .eq. "cmc" then
	lines_m = 82
end if
if model .eq. "ukmet" then
	lines_m = 50
end if

endvar = lines_m - 1

track_url = "./"
fileread := asciiread(track_url+model+"_det_mean_"+int_time+"_"+TCname+".csv",(/lines_m,9/),"float")

yyyy_arr := new(lines_m,double,-9999999)
mm_arr := new(lines_m,double,-9999999)
dd_arr := new(lines_m,double,-9999999)
hh_arr := new(lines_m,double,-9999999)
rlat_arr := new(lines_m,float,-9999999)
rlon_arr := new(lines_m,float,-9999999)
pres_arr := new(lines_m,double,-9999999)
;anom_arr := new(lines_m,double,-9999999)
cyc_arr := new(lines_m,double,-9999999)

do timestep = 0,endvar

number = timestep + 1
;print("Obtaining line: "+number+" of "+lines_m)

yyyy = flt2dble(fileread(timestep,0))
mm = flt2dble(fileread(timestep,1))
dd = flt2dble(fileread(timestep,2))
hh = flt2dble(fileread(timestep,3))
pres = decimalPlaces(flt2dble(fileread(timestep,4)),2,True)
rlat = tofloat(fileread(timestep,5))
rlon = tofloat(fileread(timestep,6))
;anom = flt2dble(fileread(timestep,7))
cyc = flt2dble(fileread(timestep,8))

yyyy_arr(timestep) = yyyy
mm_arr(timestep) = mm
dd_arr(timestep) = dd
hh_arr(timestep) = hh
pres_arr(timestep) = pres
rlat_arr(timestep) = rlat
rlon_arr(timestep) = rlon
;anom_arr(timestep) = anom
cyc_arr(timestep) = cyc

end do    ; end timestep (aka: finding lat/lons to plot)

print(" ")
print("Lat/Lons successfully collected from file")

;************************************************************************

tkres = True
tkres@gsLineColor = "red3"
tkres@gsLineThicknessF = 14

dres = True
dres@gsMarkerColor = "red3"
dres@gsMarkerIndex = 1
dres@gsMarkerSizeF = 0.020

timres = True
timres@txFontHeightF = .008 

length = doubletoint(cyc_arr(endvar))
line2 = new(lines_m,graphic)
dot3 = new(lines_m,graphic)
dot4 = new(lines_m,graphic)

l_lat := new(lines_m,double,0)
l_lon := new(lines_m,double,0)
previous_cyc = todouble(-1)

start_position = 0
spot = 0
cyc_num = 1

;***********************************************************

startpoint = 0
toolong = 0

do i = 1,endvar
  previous2_cyc = todouble(-2)
  previous_cyc = cyc_arr(i-1)
  current_cyc = cyc_arr(i)
  l_lat(i-1) = rlat_arr(i-1)
  l_lon(i-1) = rlon_arr(i-1)
  l_lat(i) = rlat_arr(i)
  l_lon(i) = rlon_arr(i)
 
print("current_cyc: "+current_cyc+" | previous_cyc: "+previous_cyc)
 
	if (current_cyc .ne. previous_cyc) .or. (i .eq. endvar) then
		print(" ")
   		print("******Starting cyclone "+previous_cyc+"******")
   		cyc_num = cyc_num + 1
   		if i .eq. endvar then
   			endpoint = i-1
   		else
   		    endpoint = i-2
   		end if
   		
   		print("startpoint: "+startpoint)
   		print("endpoint: "+endpoint)

  		do h = startpoint,endpoint
  	  		spot = spot + 1
;  			print("Line Drawn: "+spot)
  			l_lat_plot := (/l_lat(h),l_lat(h+1)/)
    		l_lon_plot := (/l_lon(h),l_lon(h+1)/)
;    		print("last lat: "+l_lat(h+1))
    
print("cyc_num: "+cyc_num)
	
    		if cyc_num .eq. 2 then
        		tkres@gsLineColor = "blue2"
;			tkres@gsLineThicknessF = 16
				dres@gsMarkerColor = tkres@gsLineColor    		
    		end if
    		if cyc_num .eq. 3 then
        		tkres@gsLineColor = "red2"
;			tkres@gsLineThicknessF = 13
				dres@gsMarkerColor = tkres@gsLineColor    		
    		end if


			line2(spot-1) = gsn_add_polyline(wks,plot,l_lon_plot,l_lat_plot,tkres)
			
			if hh_arr(h) .eq. 0 .or. hh_arr(h) .eq. 12 then
;			print("hh: "+hh_arr(h))
			dot3(spot-1) = gsn_add_polymarker(wks,plot,l_lon(h),l_lat(h),dres)			
			end if
			
			if (h .eq. endpoint) .and. (hh_arr(h) .eq. 6 .or. hh_arr(h) .eq. 18) then
			    print("At endpoint!")
				dot4(spot-1) = gsn_add_polymarker(wks,plot,l_lon(h+1),l_lat(h+1),dres)
			end if
			
		end do ; end h
		
		startpoint = i
	end if
	
	previous_cyc = cyc_arr(i)
	previous2_cyc = cyc_arr(i-1)
end do  ; end plot tracks 

;************************************************************************
;************************************************************************
;************************************************************************
;************************************************************************

; Read in file with cyclone tracks
lines = 76
endvar = lines - 1

track_url = "./"
fileread := asciiread(track_url+"best_track_"+TCname+".csv",(/lines,9/),"float")

yyyy_arr := new(lines,double,-9999999)
mm_arr := new(lines,double,-9999999)
dd_arr := new(lines,double,-9999999)
hh_arr := new(lines,double,-9999999)
rlat_arr := new(lines,float,-9999999)
rlon_arr := new(lines,float,-9999999)
pres_arr := new(lines,double,-9999999)
;anom_arr := new(lines,double,-9999999)
cyc_arr := new(lines,double,-9999999)

do timestep = 0,endvar

number = timestep + 1
;print("Obtaining line: "+number+" of "+lines)

yyyy = flt2dble(fileread(timestep,0))
mm = flt2dble(fileread(timestep,1))
dd = flt2dble(fileread(timestep,2))
hh = flt2dble(fileread(timestep,3))
pres = decimalPlaces(flt2dble(fileread(timestep,4)),2,True)
rlat = tofloat(fileread(timestep,5))
rlon = tofloat(fileread(timestep,6))
;anom = flt2dble(fileread(timestep,7))
cyc = flt2dble(fileread(timestep,8))

yyyy_arr(timestep) = yyyy
mm_arr(timestep) = mm
dd_arr(timestep) = dd
hh_arr(timestep) = hh
pres_arr(timestep) = pres
rlat_arr(timestep) = rlat
rlon_arr(timestep) = rlon
;anom_arr(timestep) = anom
cyc_arr(timestep) = cyc

end do    ; end timestep (aka: finding lat/lons to plot)

print(" ")
print("Lat/Lons successfully collected from file")

;************************************************************************

tkres = True
tkres@gsLineColor = "black"
tkres@gsLineThicknessF = 12

dres = True
dres@gsMarkerColor = "black"
dres@gsMarkerIndex = 1
dres@gsMarkerSizeF = 0.018

timres = True
timres@txFontHeightF = .008 

length = doubletoint(cyc_arr(endvar))
line = new(lines,graphic)
dot = new(lines,graphic)
dot2 = new(lines,graphic)
time = new(lines,graphic)
time2 = new(lines,graphic)

l_lat := new(lines,double,0)
l_lon := new(lines,double,0)
previous_cyc = todouble(-1)

start_position = 0
spot = 0
cyc_num = 1
array2check = ispan(945,1000,1)

;***********************************************************

startpoint = 0
toolong = 0

do i = 1,endvar
  previous2_cyc = todouble(-2)
  previous_cyc = cyc_arr(i-1)
  current_cyc = cyc_arr(i)
  l_lat(i-1) = rlat_arr(i-1)
  l_lon(i-1) = rlon_arr(i-1)
  l_lat(i) = rlat_arr(i)
  l_lon(i) = rlon_arr(i)
  
	if (current_cyc .ne. previous_cyc) .or. (i .eq. endvar) then
		print(" ")
   		print("******Starting cyclone "+previous_cyc+"******")
   		cyc_num = cyc_num + 1
   		endpoint = i-1
   		
   		print("startpoint: "+startpoint)
   		print("endpoint: "+endpoint)

  		do h = startpoint,endpoint
  	  		spot = spot + 1
;  			print("Line Drawn: "+spot)
  			l_lat_plot := (/l_lat(h),l_lat(h+1)/)
    		l_lon_plot := (/l_lon(h),l_lon(h+1)/)
;    		print("last lat: "+l_lat(h+1))
    	
    		value2check := pres_arr(h)
    		index = closest_val(value2check,array2check)
    		tkres@gsLineColor = "black"            ;colors(index)
			line(spot-1) = gsn_add_polyline(wks,plot,l_lon_plot,l_lat_plot,tkres)
			
			if hh_arr(h) .eq. 0 .or. hh_arr(h) .eq. 12 then
;			print("hh: "+hh_arr(h))
			dot(spot-1) = gsn_add_polymarker(wks,plot,l_lon(h),l_lat(h),dres)			
			
				if hh_arr(h) .eq. 0 then
				label = dd_arr(h)
				time(spot-1) = gsn_add_text(wks,plot,tofloat(label),l_lon(h),l_lat(h)-1.0,timres)
				end if
			end if
			
			if (h .eq. endpoint) .and. (hh_arr(h) .eq. 6 .or. hh_arr(h) .eq. 18) then
			    print("At endpoint!")
			    print(" ")
				dot2(spot-1) = gsn_add_polymarker(wks,plot,l_lon(h+1),l_lat(h+1),dres)
			end if
			
		end do ; end h
		
		startpoint = i
	end if
	
	previous_cyc = cyc_arr(i)
	previous2_cyc = cyc_arr(i-1)
end do  ; end plot tracks 

;********************************************

draw(plot)
frame(wks)

;********************************************

system("convert -trim "+name+".png "+name+".png")
system ("scp "+name+".png abentley@emcrzdm:"+dir_out_web+".")

print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end
