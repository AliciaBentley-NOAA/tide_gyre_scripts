; ===========================================
; Plot global model MSLP forecasts
; Created by: Alicia M. Bentley
; Last updated: 7/15/2019
; ===========================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/calendar_decode2.ncl"
; ===========================================

begin

print(" ")
print("**************")
print(" START SCRIPT ")
print("**************")

;Initialization Date
syyyy = 2019
smm = 8
sdd = 23
shh = 12


;Forecast hour
;fhr = ispan(216,240,6)
fhr = (/24/)

data_loc = "/meso/noscrub/Alicia.Bentley/meg/dorian/"
dir_out_web = "/home/people/emc/www/htdocs/users/Alicia.Bentley/temp/"

;----------------------------------------
; Loops from initalization through fhr
;----------------------------------------
folder2 = (/"ecmwf"/)
;folder2 = (/"ecmwf","gfsv15","gfsv14","gefs","eps","analysis"/)
enddomain2 = dimsizes(folder2)

do r = 0,enddomain2-1
model = folder2(r)


timeUnits = "hours since 1800-01-01 00:00:00"
sdate = cd_inv_calendar(syyyy,smm,sdd,shh,00,00,timeUnits,0)
;edate = cd_inv_calendar(eyyyy,emm,edd,ehh,00,00,timeUnits,0)

print("sdate: "+ut_string(sdate,""))
;print("edate: "+ut_string(edate,""))

imgcount = 1

;------------------------------------------

nfhr = dimsizes(fhr)

do f = 0,nfhr-1
    if (fhr(f).lt.10) then
    	FF = "0"+fhr(f)    
	FFF = "00"+fhr(f)
    else if ((fhr(f) .ge. 10) .and. (fhr(f) .lt. 100)) then
        FF = fhr(f) 
	FFF = "0"+fhr(f)
    else if (fhr(f) .ge. 100) then
        FF = fhr(f)
        FFF = fhr(f)
    end if
    end if
    end if
    print("FF: "+FF+" | FFF: "+FFF)

    fhrm24 = fhr - 24

    if (fhrm24.lt.10) then
        FFm24 = "0"+fhrm24
        FFFm24 = "00"+fhrm24
    else if ((fhrm24 .ge. 10) .and. (fhrm24 .lt. 100)) then
        FFm24 = fhrm24
        FFFm24 = "0"+fhrm24
    else if (fhrm24 .ge. 100) then
        FFm24 = fhrm24
        FFFm24 = fhrm24
    end if
    end if
    end if
    print("FFm24: "+FFm24+" | FFFm24: "+FFFm24)


int_date = ut_string(sdate,"%Y%N%D")
print("int_date: "+int_date)
int_hh = ut_string(sdate,"%H")
print("int_hh: "+int_hh)
print(" ")

curdate = sdate
curdate = sdate + fhr(f)

end_date = ut_string(curdate,"%Y%N%D")
print("end_date: "+end_date)
end_hh = ut_string(curdate,"%H")
print("end_hh: "+end_hh)

;--------------------

print(" ")
name = model+"_mslp_val_"+end_date+end_hh+"_f"+FFF
print("name: "+name)
print(" ")

;---------------------


if (model .eq. "analysis") then

   print("Looking for analysis!")
   anl_in = data_loc+int_date+int_hh+"/gfsv15/gfs.t"+int_hh+"z.pgrb2.0p25.anl.grib2"
   print("anl_in: "+anl_in)
   a = addfile(anl_in,"r")
   mslp = a->MSLET_P0_L101_GLL0(:,:)
   mslp = mslp * .01     ; convert Pa to hPa

end if




if (model .eq. "gfsv15") then

   gfsv15_in = data_loc+int_date+int_hh+"/gfsv15/gfs.t"+int_hh+"z.pgrb2.0p25.f"+FFF+".grib2"
   print("gfsv15_in: "+gfsv15_in)
   a = addfile(gfsv15_in,"r")
   mslp = a->MSLET_P0_L101_GLL0(:,:)
   mslp = mslp * .01     ; convert Pa to hPa

end if   ; gfsv15








if (model .eq. "gfsv14") then

     gfsv14_in = data_loc+int_date+int_hh+"/gfsv14/gfs.t"+int_hh+"z.pgrb2.0p25.f"+FFF+".grib2"
     print("gfsv14_in: "+gfsv14_in)
     a = addfile(gfsv14_in,"r")
     mslp = a->MSLET_P0_L101_GLL0(:,:)
     mslp = mslp * .01     ; convert Pa to hPa

end if   ; gfsv14





if (model .eq. "ecmwf") then

     ecmwf_in = "/meso/noscrub/Alicia.Bentley/meg/dorian/eps/ecmwf_0p5_both.grb2"
     print("ecmwf_in: "+ecmwf_in)
     a = addfile(ecmwf_in,"r")
     mslp = a->msl_P0_L101_GLL0({sdate},{fhr},::-1,:)
     mslp = mslp * .01     ; convert Pa to hPa

end if   ; ecmwf






if (model .eq. "gefs") then

     gefs_in = data_loc+int_date+int_hh+"/gefs/geavg."+int_date+".t"+int_hh+"z.pgrb2a.0p50.f"+FFF+".grib2"
     print("gefs_in: "+gefs_in)
     a = addfile(gefs_in,"r")
     mslp = a->PRMSL_P2_L101_GLL0(:,:)
     mslp = mslp * .01     ; convert Pa to hPa

end if   ; gefs






if (model .eq. "eps") then

 pmsl := new((/51,361,720/),"float")
;pmsl := new((/51,181,360/),"float")

  do e = 0,1
        if (e .eq. 0) then
                ens_file := data_loc+"EPS/eps_0p50_control.grib2"
                a := addfile(ens_file,"r")
                ens_mslp := a->msl_P1_L101_GLL0({sdate},{fhr},::-1,:)
                ens_mslp = ens_mslp * .01
;               printMinMax(ens_mslp,True)
;               printVarSummary(ens_mslp)
                pmsl(e,:,:) = ens_mslp
        else
                if (e .lt. 10) then
                     ens = "0"+e
                else if (e .ge. 10) then
                     ens = e
                end if
                end if

                ens_file := data_loc+"EPS/eps_0p50_members.grib2"
                b := addfile(ens_file,"r")
                ens_mslp := b->msl_P1_L101_GLL0(:,{sdate},{fhr},::-1,:)
                ens_mslp = ens_mslp * .01
                pmsl(1:50,:,:) = ens_mslp
        end if
  end do ; e

  ;spr_mslp = dim_stddev_n_Wrap(pmsl,0)
  mslp := dim_avg_n_Wrap(pmsl,0) 

end if    ; end eps



print(" ")
print("Successfully got data from files!")
print(" ")

;-----------------------------------------------------------------------

folder = (/"zoom"/)
;folder = (/"pacific","atlantic","europe","northamer"/)
enddomain = dimsizes(folder)

do x = 0,enddomain-1

        domain = folder(x)

        print("Plotting maps for: "+domain)
        print(" ")

        dir_plot = "./"
        dir_out = dir_plot
;       print("dir_out: "+dir_out)

;==============================================
; Create Shaded Map
;==============================================

wks_type = "png"

wks_type@wkWidth = 1600
wks_type@wkHeight = 1600

wks = gsn_open_wks(wks_type,dir_plot+name)
gsn_define_colormap(wks,"thetae")                                 ; "sunshine_9lev")

;**********************************************

res = True

res@gsnFrame = False                                             ;DO NOT PLOT FIRST MAP
res@gsnDraw = False

res@mpDataBaseVersion = "MediumRes"                              ; Country Outlines
res@mpDataSetName = "Earth..4"
res@mpOutlineBoundarySets = "National"
res@cnFillOn = True                                              ; Turn on color fill
res@cnFillMode = "AreaFill"
res@cnRasterSmoothingOn = True
res@cnLevelSpacingF = 1                            ; Shading interval
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLinesOn = True                               ; Turn off contour lines
res@cnLevels=fspan(920,1060,36)
;res@cnLevels = (/.01,.1,.25,.50,.75,1.0,1.25,1.5,1.75,2.0,2.5,3.0,4.0,5.0,6.0/)
;res@cnFillColors = (/-1,93,85,76,23,34,45,53,193,184,175,164,156,142,134,126,115,108,201/)

res@cnLineLabelsOn = True
res@cnLabelMasking = True
res@cnLineThicknessF = 9                     ; Changes thickness of contours
res@cnLineLabelAngleF = 0.0
res@cnLineLabelInterval = 1
res@cnLineLabelDensityF = .60
;res@cnSmoothingOn = True
;res@cnSmoothingDistanceF = 0.009
res@cnLineLabelBackgroundColor = -1
res@cnLineLabelFontHeightF = 0.012
res@gsnAddCyclic =  True
res@cnLineColor = "black"
res@cnLineLabelFontColor = res@cnLineColor

res@cnLowLabelsOn=True
res@cnLowLabelBackgroundColor=-1
res@cnLowLabelFontColor="red2"
res@cnLowLabelFont = "helvetica-bold"
res@cnHighLabelFontHeightF=.025

;**********************************************

res@lbAutoManage = False                   ; Label Bar Information
res@pmLabelBarOrthogonalPosF = -.058
res@pmLabelBarHeightF = 0.08
res@pmLabelBarWidthF = 0.60
res@lbLabelAutoStride = True
res@lbLabelFontHeightF = 0.0124
res@lbBoxLinesOn  = True                   ; Outline the color bar
res@lbTopMarginF = .3

; *********************************************

res@mpGeophysicalLineThicknessF = 5.0
res@mpNationalLineThicknessF = 4.0
res@mpUSStateLineThicknessF = 4.0
res@mpOutlineSpecifiers = (/"United States"/)+" : States"

res@mpGeophysicalLineColor = "black"   ;"grey29"
res@mpNationalLineColor = res@mpGeophysicalLineColor
res@mpUSStateLineColor = res@mpGeophysicalLineColor

; *********************************************

res@mpGridAndLimbOn = True
res@mpGridLineDashPattern = 5
res@mpGridLatSpacingF = 10.
res@mpGridLonSpacingF = 10.
res@mpGridLineThicknessF = 3
res@mpGridLineColor = "grey30"
res@pmTickMarkDisplayMode = "Always"

res@tmXTOn = False
res@tmXBOn = False
res@tmYLOn = False
res@tmYROn = False

; *************************************************************


if domain .eq. "northamer"
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 31
res@mpLambertParallel1F = 11
res@mpLambertMeridianF = -100
res@mpLimitMode = "LatLon"
res@mpMinLatF = 8.
res@mpMaxLatF = 72.
res@mpMinLonF = -151.
res@mpMaxLonF = -49.
end if

if domain .eq. "easternUS"
res@mpProjection := "Mercator"
res@mpLimitMode := "LatLon"
res@mpMinLatF := 24
res@mpMaxLatF := 50
res@mpMinLonF := -103
res@mpMaxLonF := -53
end if

if domain .eq. "centralUS"
res@mpProjection := "Mercator"
res@mpLimitMode := "LatLon"
res@mpMinLatF := 21
res@mpMaxLatF := 46
res@mpMinLonF := -133
res@mpMaxLonF := -87
end if

if domain .eq. "northpac"
res@mpProjection := "Mercator"
res@mpLimitMode := "LatLon"
res@mpMinLatF := 21
res@mpMaxLatF := 53
res@mpMinLonF := -163
res@mpMaxLonF := -87
end if

if domain .eq. "zoom"
res@mpProjection := "CylindricalEquidistant"
;res@mpLimitMode := "LatLon"
res@mpMinLatF := 0.0
res@mpMaxLatF := 20.0
res@mpMinLonF := -60.
res@mpMaxLonF := -30.
end if

; *************************************************************

cnres = True

cnres@gsnFrame = False                                        
cnres@gsnDraw = False

cnres@gsnLeftString = " "
cnres@gsnRightString = " "

cnres@cnInfoLabelOn = False                    ; Removes descriptive box in lower right corner
cnres@cnFillOn = False
cnres@cnLinesOn = True
cnres@cnLabelMasking = True
cnres@cnLineThicknessF = 11                     ; Changes thickness of contours
cnres@cnLevelSelectionMode = "ManualLevels"
cnres@cnLevelSpacingF = 4
cnres@cnMinLevelValF = 800
cnres@cnMaxLevelValF = 1200 
cnres@cnLineLabelAngleF = 0.0
cnres@cnLineLabelInterval = 2
cnres@cnLineLabelDensityF = .90
;cnres@cnSmoothingOn = True
;cnres@cnSmoothingDistanceF = 0.009
cnres@cnLineLabelBackgroundColor = -1
cnres@cnLineLabelFontHeightF = 0.012
;cnres@gsnAddCyclic =  True
cnres@cnLineColor = "blue4"
cnres@cnLineLabelFontColor = cnres@cnLineColor

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
thres@cnLineThicknessF = 10
thres@cnLineColor = "red"
thres@cnLineLabelFontColor = "red"
thres@cnLevelSelectionMode = "ManualLevels"
thres@cnLevelSpacingF = 80
thres@cnMinLevelValF = 0
thres@cnMaxLevelValF = 80 
thres@cnLineLabelAngleF = 0.0
thres@cnLineLabelInterval = 3
thres@cnLineLabelDensityF = .90
thres@cnLineLabelBackgroundColor = -1
thres@cnLineLabelFontHeightF = 0.013
;thres@cnLineDashPattern = 5
;thres@gsnAddCyclic =  True

;**********************************************

    bres = True

    bres@gsnFrame = False                                        
    bres@gsnDraw = False

    bres@gsnLeftString = " "
    bres@gsnRightString = " "

    bres@vcGlyphStyle = "WindBarb"
    bres@vcWindBarbColor = "grey12"
    bres@vcWindBarbCalmCircleSizeF = 0
    bres@vcWindBarbLineThicknessF = 3.0
    bres@vcRefAnnoOn = False
    bres@vcRefLengthF = 0.0242
    bres@vcRefMagnitudeF = 10.0
    bres@vcRefAnnoString2On = False
    bres@vcRefAnnoOrthogonalPosF = -1.08
    bres@vcMinDistanceF = 0.035
    bres@vcWindBarbTickLengthF = 0.37
    bres@vcWindBarbTickSpacingF = 0.130
    bres@vcWindBarbTickAngleF = 55.0
    bres@gsnFrame = False
    bres@gsnAddCyclic =  True

;**********************************************
  curdate@units = "hours since 1800-01-01 00:00:00"
        res@tiMainString = " "
        res@tiMainJust = "CenterCenter"
        res@tiMainPosition = "Center"
        res@tiMainOffsetYF = .000
        res@tiXAxisFontHeightF = .00000001

        res@gsnLeftStringFontColor = "black"
        res@gsnLeftString = " "
        res@gsnLeftStringOrthogonalPosF = -.001
        res@gsnLeftStringParallelPosF = 0.01
        res@gsnLeftStringFontHeightF = .012

        res@gsnLeftString = "("+model+") MSLP | Int: "+ut_string(sdate,"")+" | F"+fhr+" | Val: "+ut_string(curdate,"")
        res@gsnRightString = " "
; *************************************************************
res@mpFillOn = False
res@mpOutlineOn = True
res@mpFillDrawOrder = "PreDraw"
res@cnFillDrawOrder = "PreDraw"
res@cnLineDrawOrder ="Draw"
res@cnLabelDrawOrder = "Draw"
;bres@vcVectorDrawOrder = "Draw"
res@mpOutlineDrawOrder = "Draw"
res@mpGridAndLimbDrawOrder = "PostDraw"

plot = gsn_csm_contour_map(wks, mslp, res) 
;contours = gsn_csm_contour(wks, t, thres)

;********************************************

;overlay(plot,contours)
;overlay(plot,barbs)

;********************************************

draw(plot)
frame(wks)

;----------------------------------------

system("convert -trim "+dir_plot+name+".png "+dir_plot+name+".png")
system ("scp "+dir_plot+name+".png abentley@emcrzdm:"+dir_out_web+".")

print("Image: "+dir_out_web+name+".png")
print(" ")

;***************************************************************************
;***************************************************************************
;***************************************************************************

end do          ; end domain

imgcount = imgcount + 1

end do          ; end fhr
end do		; end x (domain)

print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end
                                
