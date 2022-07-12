; ===========================================
; Plot cloud layers
; Created by: Alicia M. Bentley
; Last updated: 4/18/12019
; ===========================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/calendar_decode2.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
; ===========================================

begin

print(" ")
print("**************")
print(" START SCRIPT ")
print("**************")

;--------------------------------------------------------
; Parameters you will be changing the most are found here
;--------------------------------------------------------

;Initialization Date
syyyy = 2019
smm = 1
sdd = 28
shh = 0

domain = "northamer"

;Forecast hour
fhr = ispan(0,84,3)
;fhr = (/84/)

data_path = "/meso/save/Alicia.Bentley/MEG/cold/data/"
dir_plot = "./"
dir_out_web = "/home/people/emc/www/htdocs/users/Alicia.Bentley/test/check/"

model = "fv3"

if domain .eq. "conus" then
min_lat = 25     
max_lat = 50    
min_lon = -120
max_lon = -72.5
end if

if domain .eq. "northamer" then
min_lat = 25
max_lat = 77     
min_lon = -140
max_lon = -60
end if



count = 0

;---------------------------------------------------------------------
; Automatically setting dates and looping through forecast hours
;---------------------------------------------------------------------
timeUnits = "hours since 1800-01-01 00:00:00"
sdate = cd_inv_calendar(syyyy,smm,sdd,shh,00,00,timeUnits,0)
print("sdate: "+ut_string(sdate,""))


; Loops through the forecasts hours you said to plot (above)
nfhr = dimsizes(fhr)
do f = 0,nfhr-1                
    if (fhr(f).lt.10) then
    	FF = "0"+fhr(f)    
	FFF = "00"+fhr(f)
    else if ((fhr(f) .ge. 10) .and. (fhr(f) .lt. 100)) then
        FF = fhr(f) 
	FFF = "0"+fhr(f)
    else if (fhr(f) .ge. 100) then
        FFF = fhr(f)
    end if
    end if
    end if
    print("FF: "+FF+" | FFF: "+FFF)

int_date = ut_string(sdate,"%Y%N%D")
print("int_date: "+int_date)
int_hh = ut_string(sdate,"%H")
print("int_hh: "+int_hh)
print(" ")

curdate = sdate
curdate = sdate + fhr(f)

;system("wgrib2 "+data_path+"fv3gfstest."+int_date+".t"+int_hh+"z.pgrb2.0p25.f"+FFF+" -set_grib_type same -new_grid_winds earth -new_grid ncep grid 221 "+data_path+"fv3gfstest."+int_date+".t"+int_hh+"z.pgrb2.awip32.f"+FFF+".grib2")

prod=addfile(data_path+"nam."+int_date+".t"+int_hh+"z.awip32"+FF+".tm00.grib2","r")
cgfs=addfile(data_path+"gfs."+int_date+".t"+int_hh+"z.pgrb2.0p25.f"+FFF+".grib2","r")
newc=addfile(data_path+"fv3gfstest."+int_date+".t"+int_hh+"z.pgrb2.0p25.f"+FFF+".grib2","r")

;***************************************************************
; Name the image you are creating
;***************************************************************

print(" ")
name = model+"_3panel_sensible_HF_"+domain+"_"+int_date+int_hh+"_"+count
print("name: "+name)

;***************************************************************
; Extract data from files!
;***************************************************************

   nprod=prod->SHTFL_P0_L1_GLC0(:,:)

  lat2d = prod->gridlat_0
  lon2d = prod->gridlon_0

nprod@lat2d = lat2d
nprod@lon2d = lon2d

if fhr(f) .eq. 0 then
   ncgfs = nprod
   nnewc = nprod
   ncgfs = 0.0
   nnewc = 0.0
else if fhr(f) .lt. 9 then
   ncgfs:=cgfs->SHTFL_P8_L1_GLL0_avg(:,:)
   nnewc:=newc->SHTFL_P8_L1_GLL0_avg(:,:)
else if fhr(f) .eq. 9 .or. fhr(f) .eq. 15 .or. fhr(f) .eq. 21 .or. fhr(f) .eq. 27 .or. fhr(f) .eq. 33 .or. fhr(f) .eq. 39 .or. fhr(f) .eq. 45 .or. fhr(f) .eq. 51 .or. fhr(f) .eq. 57 .or. fhr(f) .eq. 63 .or. fhr(f) .eq. 69 .or. fhr(f) .eq. 75 .or. fhr(f) .eq. 81 then
   ncgfs:=cgfs->SHTFL_P8_L1_GLL0_avg3h(:,:)
   nnewc:=newc->SHTFL_P8_L1_GLL0_avg3h(:,:)
else if fhr(f) .eq. 12 .or. fhr(f) .eq. 18 .or. fhr(f) .eq. 24 .or. fhr(f) .eq. 30 .or. fhr(f) .eq. 36 .or. fhr(f) .eq. 42 .or. fhr(f) .eq. 48 .or. fhr(f) .eq. 54 .or. fhr(f) .eq. 60 .or. fhr(f) .eq. 66 .or. fhr(f) .eq. 72 .or. fhr(f) .eq. 78 .or. fhr(f) .eq. 84 then
   ncgfs:=cgfs->SHTFL_P8_L1_GLL0_avg6h(:,:)
   nnewc:=newc->SHTFL_P8_L1_GLL0_avg6h(:,:)
end if
end if
end if
end if

;-------------------------------------------------

print(" ")
print("Successfully got data from files!")
print(" ")

;==============================================
; Create Shaded Map
;==============================================

wks_type = "png"

wks_type@wkWidth = 1600
wks_type@wkHeight = 1600

wks = gsn_open_wks(wks_type,dir_plot+name)
gsn_define_colormap(wks,"BlueWhiteOrangeRed")

  plot=new(3,"graphic")

;**********************************************

res = True

res@gsnFrame = False                                             ;DO NOT PLOT FIRST MAP
res@gsnDraw = False

res@mpDataBaseVersion = "MediumRes"                              ; Country Outlines
res@mpDataSetName = "Earth..4"
;res@mpOutlineBoundarySets = "National"
res@cnFillOn = True                                              ; Turn on color fill
res@cnFillMode = "RasterFill"
res@cnRasterSmoothingOn = True
res@cnLinesOn = False                               ; Turn off contour lines
res@cnLevelSpacingF = 1                            ; Shading interval
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLinesOn = False                               ; Turn off contour lines
;res@cnLevels := (/0.005,0.0075,0.01,0.025,0.05,0.075,0.1,0.25,0.5/)
;res@cnFillColors = (/-1,49,65,81,115,167,178,190,210,241,253/)
res@cnLevels=fspan(-100,100,21)
;res@cnLevels=fspan(-40,110,26)
;res@gsnAddCyclic =  True

;**********************************************
; Manage Label Bar (Color Bar)
;*********************************************

res@lbAutoManage = False                   ; Color Bar Information
res@pmLabelBarOrthogonalPosF = -.042	   ; Moves the position of the colorbar up or down	
res@pmLabelBarHeightF = 0.08
res@pmLabelBarWidthF = 0.60
res@lbLabelAutoStride = True
res@lbLabelFontHeightF = 0.0100
res@lbBoxLinesOn  = True                   ; Outline the color bar
res@lbTopMarginF = .3

; *********************************************

res@mpGeophysicalLineThicknessF = 2.5
res@mpNationalLineThicknessF = 2.0
res@mpUSStateLineThicknessF = 2.0
res@mpOutlineSpecifiers = (/"United States"/)+" : States"

res@mpGeophysicalLineColor = "black"
;res@mpNationalLineColor = res@mpGeophysicalLineColor
;res@mpUSStateLineColor = res@mpGeophysicalLineColor

; *********************************************

res@mpGridAndLimbOn = False
res@mpGridLineDashPattern = 5
res@mpGridLatSpacingF = 10.
res@mpGridLonSpacingF = 10.
res@mpGridLineThicknessF = 3
res@mpGridLineColor = "grey50"
res@pmTickMarkDisplayMode = "Always"

res@tmXTOn = False
res@tmXBOn = False
res@tmYLOn = False
res@tmYROn = False

; *************************************************************

if domain .ne. "global" then
res@mpProjection := "LambertConformal"
res@mpLimitMode := "LatLon"
res@mpMinLatF := min_lat
res@mpMaxLatF := max_lat
res@mpMinLonF := min_lon
res@mpMaxLonF := max_lon
end if

if domain .eq. "global" then
res@mpProjection := "CylindricalEquidistant"
res@mpLimitMode := "LatLon"
res@mpMinLatF := -90.0
res@mpMaxLatF := 90.0
res@mpMinLonF := -180.0
res@mpMaxLonF := 180.0
end if




res@mpLambertParallel1F = 33.0         ; two parallels
res@mpLambertParallel2F = 45.0
res@mpLambertMeridianF  = -100.0        ; central meridian
; *************************************************************

thres = True

thres@gsnFrame = False
thres@gsnDraw = False

thres@gsnLeftString = " "
thres@gsnRightString = " "
thres@cnInfoLabelOn = False                    ; Removes descriptive box in lower right corner
thres@cnFillOn = False
thres@cnLinesOn = True
thres@cnLabelMasking = True
thres@cnLineThicknessF = 4
thres@cnLineColor = "red"
thres@cnLineLabelFontColor = "red"
thres@cnLevelSelectionMode = "ExplicitLevels"
thres@cnLevels=(/32/)
thres@cnLineLabelAngleF = 0.0
thres@cnLineLabelInterval = 3
thres@cnLineLabelDensityF = .70
thres@cnLineLabelBackgroundColor = -1
thres@cnLineLabelFontHeightF = 0.008
;thres@cnLineDashPattern = 5
;thres@gsnAddCyclic =  True

;**********************************************
  curdate@units = "hours since 1800-01-01 00:00:00"
  res@tiMainString = " "
  res@tiMainPosition = "Center"
  res@tiXAxisFontHeightF = .00000001

  res@gsnLeftStringFontColor = "black"
  res@gsnLeftString = " "
  res@gsnLeftStringOrthogonalPosF = -.001
  res@gsnLeftStringParallelPosF = 0.01
  res@gsnLeftStringFontHeightF = .012
  res@gsnRightString = " "
  res@gsnRightStringFontColor = "black"
  res@gsnRightStringOrthogonalPosF = -.001
;  res@gsnRightStringParallelPosF = 0.01
  res@gsnRightStringFontHeightF = .012

; *************************************************************
res@mpFillOn = True
res@mpOutlineOn = True
res@mpFillDrawOrder = "PreDraw"
res@cnFillDrawOrder = "PreDraw"
thres@cnLineDrawOrder ="Draw"
thres@cnFillDrawOrder = "Draw"
res@mpOutlineDrawOrder = "Draw"
res@mpGridAndLimbDrawOrder = "PostDraw"

res@gsnLeftString = "NAM Sensible Heat Flux (W m-2) | Val: "+ut_string(curdate,"")+" | F"+FFF
plot(0) = gsn_csm_contour_map(wks, nprod, res)
;other0 = gsn_csm_contour(wks, nprod_old, thres)

print("plot(1)")
res@gsnLeftString = "GFS Sensible Heat Flux (W m-2) | Val: "+ut_string(curdate,"")+" | F"+FFF
plot(1) = gsn_csm_contour_map(wks, ncgfs, res)
;other1 = gsn_csm_contour(wks, nnewc, thres)

print("plot(2)")
res@gsnLeftString = "FV3GFS Sensible Heat Flux (W m-2) | Val: "+ut_string(curdate,"")+" | F"+FFF
plot(2) = gsn_csm_contour_map(wks, nnewc, res)

;********************************************

  resP=True
  resP@gsnMaximize=True
  resP@txFontHeightF=.012
  resP@gsnPanelLabelBar=False
  resP@gsnFrame=False
  resP@gsnPanelRowSpec = True
  gsn_panel(wks,plot,(/3/),resP)

print("Stuck framing...")
;********************************************

;draw(plot)
frame(wks)

;----------------------------------------

system("convert -trim "+dir_plot+name+".png "+dir_plot+name+".png")
system ("scp "+dir_plot+name+".png abentley@emcrzdm:"+dir_out_web+".")

print("Image: "+dir_out_web+name+".png")
print(" ")

;***************************************************************************
;***************************************************************************
;***************************************************************************

count = count + 1

end do          ; end fhr

print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end
                                
