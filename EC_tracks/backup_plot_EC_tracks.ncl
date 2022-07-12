;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;;
;;
;; Plots TC track density from various ensembles
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

model = "gfs"
ECname = "bomb_cyclone"
dir_out_web = "/home/people/emc/www/htdocs/users/Alicia.Bentley/MEG/EC_tracks/"
dir_data = "/meso/save/Alicia.Bentley/MEG/EC_tracks/bomb_cyclone/"

minlat = 22.
maxlat = 59.
minlon = -79.
maxlon = -48.

;----------------------------------------------------------------------------------------------

name = model+"_tracks_"+ECname

dir_out = "./"
; scp *.png abentley@emcrzdm:/home/people/emc/www/htdocs/users/Alicia.Bentley/fv3gfs/retros/images/lane/.

;----------------------------------------------------------------------------------------------

        gfs_anl_file = addfile(dir_data+"gfs.20180101.t00z.pgrb2.0p25.f000.grib2","r")

        mslp_anl := gfs_anl_file->MSLET_P0_L101_GLL0(::-1,:)
        mslp_anl = mslp_anl/100.
;       printVarSummary(mslp_anl)

;==============================================
; Create Shaded Map
;==============================================
wks_type = "png"

wks_type@wkWidth = 2500
wks_type@wkHeight = 2500

wks = gsn_open_wks(wks_type,name)
gsn_define_colormap(wks,"GMT_hot")          ; "NCV_jet")
colors = (/97,96,95,94,93,92,91,90,89,88,87,79,78,77,76,75,74,73,72,71,70,67,66,65,64,63,62,61,60,59,58,51,50,49,48,47,46,45,44,43,42,33,32,31,30,29,28,27,26,25,24,21,20,19,18,17,16,15,14,13,12,11/)

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
res@cnLevelSelectionMode = "ManualLevels"
res@cnLinesOn = False                               ; Turn off contour lines
res@cnLineLabelsOn = False
res@cnLevelSpacingF = 1
res@cnMinLevelValF = 940
res@cnMaxLevelValF = 1000  
res@cnFillColors = colors

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

res@gsnLeftString = " "
res@gsnLeftStringOrthogonalPosF = .0075 
res@gsnLeftStringFontHeightF = .008
res@gsnRightString = " "
res@gsnRightStringOrthogonalPosF = .0075
res@gsnRightStringFontHeightF = .008


;********************************************
res@mpFillOn = True
res@mpOutlineOn = True
res@cnFillDrawOrder = "PreDraw"
res@mpFillDrawOrder = "Draw"
res@mpOutlineDrawOrder = "Draw"
res@mpGridAndLimbDrawOrder = "PostDraw"

plot = gsn_csm_contour_map(wks, mslp_anl, res) 

;************************************************************************
;************************************************************************
;************************************************************************
;************************************************************************

; Read in file with cyclone tracks

track_url = "./"
trk_read = asciiread(track_url+model+"_fcst_"+ECname+".csv",-1,"string")
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
cyc_arr_temp = str_get_field(trk_read, 10,delim)

;printVarSummary(yyyy_arr_temp)

iz = ind(yyyy_arr_temp .ge. 2017)
;print(iz)

hh_arr = todouble(hh_arr_temp(iz))
rlat_arr = todouble(rlat_arr_temp(iz))
rlon_arr = todouble(rlon_arr_temp(iz))
cyc_arr = todouble(cyc_arr_temp(iz))

print(cyc_arr)

;************************************************************************

tkres = True
tkres@gsLineColor = "blue"
tkres@gsLineThicknessF = 10

dres = True
dres@gsMarkerColor = "blue"
dres@gsMarkerIndex = 1
dres@gsMarkerSizeF = 0.018

length = doubletoint(dimsizes(cyc_arr))
line3 = new(length,graphic)
dot3 = new(length,graphic) 
dot4 = new(length,graphic)

l_lat := new(length,double,0)
l_lon := new(length,double,0)
previous_cyc = todouble(-1)

start_position = 0
spot = 0
cyc_num = 1

;printVarSummary(cyc_arr)

;************************************************************************

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
                
		if (previous_cyc .eq. 0) then
			tkres@gsLineColor = "blue"
		end if
                if (previous_cyc .eq. 1) then
                        tkres@gsLineColor = "slateblue2"
                end if
                if (previous_cyc .eq. 2) then
                        tkres@gsLineColor = "mediumpurple2"
                end if
                if (previous_cyc .eq. 3) then
                        tkres@gsLineColor = "mediumorchid2"
                end if
                if (previous_cyc .eq. 4) then
                        tkres@gsLineColor = "magenta2"
                end if
                if (previous_cyc .eq. 5) then
                        tkres@gsLineColor = "maroon3"
                end if
                if (previous_cyc .eq. 6) then
                        tkres@gsLineColor = "red"
                end if

		dres@gsMarkerColor = tkres@gsLineColor

		if i .eq. endvar then
                        endpoint = i-1
                else
                    endpoint = i-2
                end if

                print("startpoint: "+startpoint)
                print("endpoint: "+endpoint)

                do h = startpoint,endpoint
                        spot = spot + 1
;                       print("Line Drawn: "+spot)
                        l_lat_plot := (/l_lat(h),l_lat(h+1)/)
                l_lon_plot := (/l_lon(h),l_lon(h+1)/)
;               print("last lat: "+l_lat(h+1))

                        line3(spot-1) = gsn_add_polyline(wks,plot,l_lon_plot,l_lat_plot,tkres)

                        if hh_arr(h) .ge. 0 .and. hh_arr(h) .le. 18 then
;                       	print("hh: "+hh_arr(h))
                        	dot3(spot-1) = gsn_add_polymarker(wks,plot,l_lon(h),l_lat(h),dres)  
			end if
                
		        if (h .eq. endpoint) .and. (hh_arr(h) .ge. 0 .or. hh_arr(h) .le. 18) then
                            print("At endpoint!")
                            print(" ")
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


; Read in file with gfs analysis tracks

track_url = "./"
trk_read := asciiread(track_url+"gfs_anl_"+ECname+".csv",-1,"string")
delim := ", "
nfields := str_fields_count(trk_read, delim)
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

iz := ind(yyyy_arr_temp .eq. 2018)
;print(iz)

dd_arr := todouble(dd_arr_temp(iz))
hh_arr := todouble(hh_arr_temp(iz))
rlat_arr := todouble(rlat_arr_temp(iz))
rlon_arr := todouble(rlon_arr_temp(iz))
cyc_arr := todouble(cyc_arr_temp(iz))

print(" ")
print("Lat/Lons successfully collected from file")

;************************************************************************

tkres = True
tkres@gsLineColor = "black"
tkres@gsLineThicknessF = 18

dres = True
dres@gsMarkerColor = "black"
dres@gsMarkerIndex = 1
dres@gsMarkerSizeF = 0.024

timres = True
timres@txFontHeightF = .008 

length := doubletoint(dimsizes(rlat_arr))
line = new(length,graphic)
dot = new(length,graphic)
dot2 = new(length,graphic)
time = new(length,graphic)
time2 = new(length,graphic)

l_lat := new(length,double,0)
l_lon := new(length,double,0)
previous_cyc = todouble(-1)

start_position = 0
spot = 0
cyc_num = 1
array2check = ispan(945,1000,1)

;***********************************************************

startpoint = 0
toolong = 0

endvar = dimsizes(rlat_arr)-1

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
    	
 ;   		value2check := pres_arr(h)
 ;   		index = closest_val(value2check,array2check)
    		tkres@gsLineColor = "black"            ;colors(index)
			line(spot-1) = gsn_add_polyline(wks,plot,l_lon_plot,l_lat_plot,tkres)
			
			if hh_arr(h) .ge. 0 .and. hh_arr(h) .le. 18 then
;			print("hh: "+hh_arr(h))
			dot(spot-1) = gsn_add_polymarker(wks,plot,l_lon(h),l_lat(h),dres)			
			
				if hh_arr(h) .eq. 0 then
					label = dd_arr(h)
			        time(spot-1) = gsn_add_text(wks,plot,tofloat(label),l_lon(h)-0.5,l_lat(h),timres)	
			end if
			end if
	
                        if (h .eq. endpoint) .and. (hh_arr(h) .eq. 18) then
                            print("At endpoint!")
                            print(" ")
			    label = dd_arr(h+1)
                            time2(spot-1) = gsn_add_text(wks,plot,tofloat(label),l_lon(h+1)-0.5,l_lat(h+1),timres)
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
