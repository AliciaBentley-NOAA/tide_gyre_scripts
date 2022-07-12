; ===========================================
; Archive maps from Alicia's Website
; Created by: Alicia M. Bentley
; Last updated: 2/28/2018
; ===========================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
;load "~/ncl/lib/tTick.ncl"
;load "~/ncl/lib/ut_string.ncl"
;load "~/ncl/lib/latlon.ncl"
;load "~/ncl/lib/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/calendar_decode2.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
; ===========================================

begin

;system("export NCARG_COLORMAPS="$NCARG_ROOT/lib/ncarg/colormaps:/meso/save/Alicia.Bentley/MEG/dorian/"")

print(" ")
print("**************")
print(" START SCRIPT ")
print("**************")

;toplot = "no"
toplot = "yes"

identify = "off"
;identify = "on"

;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------
model = "eps"

yyyy = 2019
mm = 8
dd = 18
hh = 00

fhr = 156

minlat = 0.0
maxlat = 20.0
minlon = -60.
maxlon = -30.

dir_out_web = "/home/people/emc/www/htdocs/users/Alicia.Bentley/temp/"

;------------------------------

        imgcount = 0                    ;;; this starts the image count at 0
                                                                                
        print(" ")
        timeUnits = "hours since 1800-01-01 00:00:00"
        sdate = cd_inv_calendar(yyyy,mm,dd,hh,00,00,timeUnits,0)

        print("sdate: "+ut_string(sdate,""))

        save_date = ut_string(sdate,"%Y%N%D")
        print("save_date: "+save_date)
        save_hh = ut_string(sdate,"%H")
        print("save_hh: "+save_hh)

file_in = "/meso/noscrub/Alicia.Bentley/meg/dorian/eps/"
dir_plot = "./"

;*****************************************************
; Loop through forecast hours
;*****************************************************

if toplot .eq. "yes" then

;       fhr  = ispan(0,264,6)
;       fhr = 6
        ;print(fhr)i
        nfhr = dimsizes(fhr)

do f = 0,nfhr-1
        if (fhr(f).lt.10) then
        filefhr = "00"+fhr(f)
    else if ((fhr(f) .gt. 10) .and. (fhr(f) .lt. 100)) then
        filefhr = "0"+fhr(f)
    else if (fhr(f) .ge. 100) then
        filefhr = fhr(f)
    end if
    end if
    end if
    print("filefhr: "+filefhr)

        fhr_cur = fhr(f)

        name = "mslp_"+model+"_"+save_date+save_hh
        print("name: "+name)


;**********************************************************************************************************
;**********************************************************************************************************
;**********************************************************************************************************

 mslp := new((/51,361,720/),"float")
;mslp := new((/51,181,360/),"float")

  do e = 0,1
        if (e .eq. 0) then
                ens_file := file_in+"eps_control_"+save_hh+"Z.grb2"
                a := addfile(ens_file,"r")
                ens_mslp := a->msl_P1_L101_GLL0({sdate},{fhr},::-1,:)
                ens_mslp = ens_mslp * .01
;               printMinMax(ens_mslp,True)
;               printVarSummary(ens_mslp)
                mslp(e,:,:) = ens_mslp
        else
                if (e .lt. 10) then
                ens = "0"+e
        else if (e .ge. 10) then
                ens = e
                end if
        end if
                ens_file := file_in+"eps_members_"+save_hh+"Z.grb2"
                b := addfile(ens_file,"r")
                ens_mslp := b->msl_P1_L101_GLL0(:,{sdate},{fhr},::-1,:)
                ens_mslp = ens_mslp * .01
                mslp(1:50,:,:) = ens_mslp
    end if
  end do ; e

spr_mslp = dim_stddev_n_Wrap(mslp,0)

ens_mslp := a->msl_P1_L101_GLL0({sdate},{fhr},::-1,:)

  print("Successfully got data from files!")

;*********************************************************************
; Isolate MSLP values within ______ km of location of formation
;*********************************************************************

if identify .eq. "on" then

rad_search = 600.0 ; radius we search outward to (km)
intdist = toint(rad_search)

R = 287.0       ; specific gas constant for dry air (J kg^-1 K^-1)
g = 9.80665             ; gravitational acceleration (m s^-2)
pi = 355./113.

;printVarSummary(ens_mslp)
ens_mslp@_FillValue = 9.969209968386869e+36

;;-----------------------------------------------------------------
;;  Calculate Great Circle Distances between points
;;-----------------------------------------------------------------

        lat_tot = conform(ens_mslp,ens_mslp&lat_0,0)
        lon_tot = conform(ens_mslp,ens_mslp&lon_0,1)
;        printVarSummary(lat_tot)
        lat_tot@_FillValue = 9.969209968386869e+36
        lon_tot@_FillValue = 9.969209968386869e+36

    lat_EWE = ens_mslp&lat_0
    lon_EWE = ens_mslp&lon_0
;    printVarSummary(lat_EWE)

    lat_EWE = (/29.3/)
    lon_EWE = (/360-91.9/)
;    printVarSummary(lat_EWE)
;    print(" ")

    r = 6370. ; radius of spherical Earth (km)
    d2r = 0.0174532925199433 ; degrees to radians conversion factor

    lat1 = lat_tot
    lon1 = lon_tot
    lat2 = conform(ens_mslp,lat_EWE,0)
    lon2 = conform(ens_mslp,lon_EWE,1)

    lat1 = lat1*d2r
    lon1 = lon1*d2r
    lat2 = lat2*d2r
    lon2 = lon2*d2r


    dlat = lat2-lat1
    dlon = lon2-lon1
    latTerm = sin(.5*dlat)
    latTerm = latTerm*latTerm
    lonTerm = sin(.5*dlon)
    lonTerm = lonTerm*lonTerm*cos(lat1)*cos(lat2)
    dAngle = sqrt(latTerm+lonTerm)
    dist = 2.*r*asin(dAngle)
copy_VarCoords(ens_mslp,dist)
;printVarSummary(dist)
;print(dist({20.0},{360.0-90.0}))


;;-----------------------------------------------------------------

circ_calc = where((dist .le. rad_search),2,0)
copy_VarCoords(ens_mslp,circ_calc)

ens_mslp = where((circ_calc .eq. 2),ens_mslp,ens_mslp@_FillValue)
;printVarSummary(circ_calc)

;------------------------------------------------------------------

count = 0

mslp_ident = mslp
;printVarSummary(mslp_ident)

do ident = 0,50
   mslp_ident(ident,:,:) = where((circ_calc .eq. 2),mslp(ident,:,:),mslp@_FillValue)

  locmin = local_min(mslp(ident,:,:),False,0.)
;  printVarSummary(locmin)

  xi:=mslp_ident&lon_0(locmin@xi)
  yi:=mslp_ident&lat_0(locmin@yi)

;  print(xi)

;----------------------------- Find if minima arelocated inside circle

length = dimsizes(xi)
;print(length)

find_one = 0

do j = 0,length-1
;       print("yi(j): "+yi(j)+" xi(j): "+xi(j))

;       print(mslp_ident(ident,{yi(j)},{xi(j)}))
        if ismissing(mslp_ident(ident,{yi(j)},{xi(j)})) .eq. False then
                if (mslp_ident(ident,{yi(j)},{xi(j)}) .lt. 1008.25) .and. (find_one .eq. 0) then
                        find_one = 1
                        print("yi(j): "+yi(j)+" xi(j): "+(xi(j)-360.))
                        print("mslp: "+mslp_ident(ident,{yi(j)},{xi(j)}))
                        count = count + 1
                end if
        end if
end do ; loop through all local minima

print("Member "+ident+" is done!")
print("Count = "+count)
end do

if model .eq. "gefs" then
        percentage = (count/21.)*100.
end if

if model .eq. "eps" then
        percentage = (count/51.)*100.
end if

print(" ")
print("Model: "+model)
print("Number of mems w/ Low < 1008 hPa: "+count)
print("Percentage of mems: "+percentage+"%")
print(" ")

end if  ; identify .eq. "on"
;-----------------------------------------------------------------------


folder = (/"zoom"/)
;folder = (/"CAG","GOM","pacific","atlantic","europe","northamer"/)
enddomain = dimsizes(folder)

do x = 0,enddomain-1

        domain = folder(x)

        print("Plotting maps for: "+domain)

        dir_out = dir_plot
;       system("mkdir "+dir_out)
        print("dir_out: "+dir_out)

;==============================================
; Create Shaded Map
;==============================================

wks_type = "png"

wks_type@wkWidth = 1600
wks_type@wkHeight = 1600

wks = gsn_open_wks(wks_type,dir_plot+name+"_"+filefhr)
gsn_define_colormap(wks,"alicia")

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
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLinesOn = False                               ; Turn off contour lines
res@cnLevelSpacingF = 1                            ; Shading interval
;res@cnLevels = (/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15/)
res@cnLevels = (/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18/)
res@cnFillColors = (/-1,11,12,13,14,16,18,19,20,35,37,38,24,25,26,27,28,29,0/)

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
res@mpGridLineColor = "grey50"
res@pmTickMarkDisplayMode = "Always"

res@tmXTOn = False
res@tmXBOn = False
res@tmYLOn = False
res@tmYROn = False

; *************************************************************


if domain .eq. "GOM" then
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 1
res@mpLambertParallel1F = 2
res@mpLambertMeridianF = -90
res@mpLimitMode = "LatLon"
res@mpMinLatF = 15.
res@mpMaxLatF = 37.
res@mpMinLonF = -100.
res@mpMaxLonF = -75.
delete(tmres@tmXBValues)
tmres@tmXBValues = ispan(-180,179,10)
delete(tmres@tmYRValues)
delete(tmres@tmYLValues)
tmres@tmYLValues = ispan(0,80,10)
tmres@tmYRValues = ispan(0,80,10)
end if


if domain .eq. "CAG" then
res@mpProjection = "LambertConformal"
res@mpLambertParallel2F = 1
res@mpLambertParallel1F = 2
res@mpLambertMeridianF = -90
res@mpLimitMode = "LatLon"
res@mpMinLatF = 18.5-10.
res@mpMaxLatF = 18.5+10.
res@mpMinLonF = -87.-10.
res@mpMaxLonF = -87+10.
delete(tmres@tmXBValues)
tmres@tmXBValues = ispan(-180,179,5)
delete(tmres@tmYRValues)
delete(tmres@tmYLValues)
tmres@tmYLValues = ispan(-80,80,5)
tmres@tmYRValues = ispan(-80,80,5)
end if

if domain .eq. "zoom"
res@mpProjection = "CylindricalEquidistant"
res@mpMinLatF = minlat
res@mpMaxLatF = maxlat
res@mpMinLonF = minlon
res@mpMaxLonF = maxlon
end if

; *************************************************************

mres = True

mres@gsnFrame = False
mres@gsnDraw = False

mres@gsnLeftString = " "
mres@gsnRightString = " "

mres@cnInfoLabelOn = False                    ; Removes descriptive box in lower right corner
mres@cnFillOn = False
mres@cnLineLabelsOn = False
mres@cnLinesOn = True
mres@cnLabelMasking = True
mres@cnLineThicknessF = 4                    ; Changes thickness of contours
mres@cnLevelSelectionMode = "ManualLevels"
mres@cnLevelSpacingF = 80
mres@cnMinLevelValF = 1008
mres@cnMaxLevelValF = 1200
mres@cnLineLabelAngleF = 0.0
mres@cnLineLabelInterval = 1
mres@cnLineLabelDensityF = 1.0
;mres@cnSmoothingOn = True
;mres@cnSmoothingDistanceF = 0.009
mres@cnLineLabelBackgroundColor = -1
mres@cnLineLabelFontHeightF = 0.008
mres@gsnAddCyclic =  True

; *************************************************************

lres = True

lres@gsnFrame = False
lres@gsnDraw = False

lres@gsnLeftString = " "
lres@gsnRightString = " "

lres@cnInfoLabelOn = False                    ; Removes descriptive box in lower right corner
lres@cnFillOn = False
lres@cnLineLabelsOn = False
lres@cnLinesOn = False
lres@gsnAddCyclic =  True

lres@cnLowLabelsOn = True
lres@cnLowLabelBackgroundColor = -1
;lres@cnLowLabelString = "$ZDV$"
;lres@cnLowLabelString = "L"
lres@cnLowLabelPerimOn = False
lres@cnLowLabelFontHeightF = 0.028
lres@cnLowLabelFontThicknessF = 4.0
lres@cnLowLabelFontColor = "red3"
lres@cnLowLabelFont = "helvetica"                ;"helvetica-bold"


lres@cnHighLabelsOn = False
lres@cnHighLabelBackgroundColor = -1
;lres@cnHighLabelString = "$ZDV$"
;lres@cnHighLabelString = "H"
lres@cnHighLabelPerimOn = False
lres@cnHighLabelFontHeightF = lres@cnLowLabelFontHeightF
lres@cnHighLabelFontThicknessF = lres@cnLowLabelFontThicknessF
lres@cnHighLabelFontColor = "blue"
lres@cnHighLabelFont = lres@cnLowLabelFont

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

;**********************************************

  curdate = sdate
  curdate = sdate + fhr_cur
  curdate@units = "hours since 1800-01-01 00:00:00"

        res@tiMainString = " "
        res@tiMainJust = "CenterCenter"
        res@tiMainPosition = "Center"
        res@tiMainOffsetYF = .02
        res@tiXAxisFontHeightF = .015

        res@gsnRightString = " "

        res@gsnLeftStringFontColor = "black"
;       res@gsnLeftString = "GEFS MSLP mean (contours, hPa) and spread (shaded, hPa); Lows (red, hPa) and Highs (blue, hPa)"
        res@gsnLeftString = "Initialized: "+ut_string(sdate,"")+" | Fhr: "+filefhr+" | Valid: "+ut_string(curdate,"")
        res@gsnLeftStringOrthogonalPosF = 0.010     ;  .040 two lines
        res@gsnLeftStringFontHeightF = .011

;       res@gsnRightStringFontColor = "black"
;       res@gsnRightString = "Initialized: "+ut_string(sdate,"")+" | Forecast hour: "+fhr_cur+" | Valid: "+ut_string(curdate,"")
;       res@gsnRightStringOrthogonalPosF = .010
;       res@gsnRightStringParallelPosF = 0.01
;        res@gsnRightStringFontHeightF = .010

; *************************************************************
res@mpFillOn = True
res@mpOutlineOn = True
res@mpFillDrawOrder = "PreDraw"
res@cnFillDrawOrder = "PreDraw"
mres@cnLineDrawOrder ="Draw"
lres@cnLineDrawOrder ="Draw"
cres@cnLineDrawOrder ="Draw"
res@mpOutlineDrawOrder = "Draw"
res@mpGridAndLimbDrawOrder = "PostDraw"

mres@tmXTOn = False
mres@tmXBOn = False
mres@tmYLOn = False
mres@tmYROn = False

lres@tmXTOn = False
lres@tmXBOn = False
lres@tmYLOn = False
lres@tmYROn = False


plot = gsn_csm_contour_map(wks, spr_mslp, res)          ; Plot filled contour map

contours0 = gsn_csm_contour(wks, mslp(0,:,:), mres)
contours1 = gsn_csm_contour(wks, mslp(1,:,:), mres)
contours2 = gsn_csm_contour(wks, mslp(2,:,:), mres)
contours3 = gsn_csm_contour(wks, mslp(3,:,:), mres)
contours4 = gsn_csm_contour(wks, mslp(4,:,:), mres)
contours5 = gsn_csm_contour(wks, mslp(5,:,:), mres)
contours6 = gsn_csm_contour(wks, mslp(6,:,:), mres)
contours7 = gsn_csm_contour(wks, mslp(7,:,:), mres)
contours8 = gsn_csm_contour(wks, mslp(8,:,:), mres)
contours9 = gsn_csm_contour(wks, mslp(9,:,:), mres)
contours10 = gsn_csm_contour(wks, mslp(10,:,:), mres)
contours11 = gsn_csm_contour(wks, mslp(11,:,:), mres)
contours12 = gsn_csm_contour(wks, mslp(12,:,:), mres)
contours13 = gsn_csm_contour(wks, mslp(13,:,:), mres)
contours14 = gsn_csm_contour(wks, mslp(14,:,:), mres)
contours15 = gsn_csm_contour(wks, mslp(15,:,:), mres)
contours16 = gsn_csm_contour(wks, mslp(16,:,:), mres)
contours17 = gsn_csm_contour(wks, mslp(17,:,:), mres)
contours18 = gsn_csm_contour(wks, mslp(18,:,:), mres)
contours19 = gsn_csm_contour(wks, mslp(19,:,:), mres)
contours20 = gsn_csm_contour(wks, mslp(20,:,:), mres)

lows0 = gsn_csm_contour(wks, mslp(0,:,:), lres)
lows1 = gsn_csm_contour(wks, mslp(1,:,:), lres)
lows2 = gsn_csm_contour(wks, mslp(2,:,:), lres)
lows3 = gsn_csm_contour(wks, mslp(3,:,:), lres)
lows4 = gsn_csm_contour(wks, mslp(4,:,:), lres)
lows5 = gsn_csm_contour(wks, mslp(5,:,:), lres)
lows6 = gsn_csm_contour(wks, mslp(6,:,:), lres)
lows7 = gsn_csm_contour(wks, mslp(7,:,:), lres)
lows8 = gsn_csm_contour(wks, mslp(8,:,:), lres)
lows9 = gsn_csm_contour(wks, mslp(9,:,:), lres)
lows10 = gsn_csm_contour(wks, mslp(10,:,:), lres)
lows11 = gsn_csm_contour(wks, mslp(11,:,:), lres)
lows12 = gsn_csm_contour(wks, mslp(12,:,:), lres)
lows13 = gsn_csm_contour(wks, mslp(13,:,:), lres)
lows14 = gsn_csm_contour(wks, mslp(14,:,:), lres)
lows15 = gsn_csm_contour(wks, mslp(15,:,:), lres)
lows16 = gsn_csm_contour(wks, mslp(16,:,:), lres)
lows17 = gsn_csm_contour(wks, mslp(17,:,:), lres)
lows18 = gsn_csm_contour(wks, mslp(18,:,:), lres)
lows19 = gsn_csm_contour(wks, mslp(19,:,:), lres)
lows20 = gsn_csm_contour(wks, mslp(20,:,:), lres)
lows21 = gsn_csm_contour(wks, mslp(21,:,:), lres)
lows22 = gsn_csm_contour(wks, mslp(22,:,:), lres)
lows23 = gsn_csm_contour(wks, mslp(23,:,:), lres)
lows24 = gsn_csm_contour(wks, mslp(24,:,:), lres)
lows25 = gsn_csm_contour(wks, mslp(25,:,:), lres)
lows26 = gsn_csm_contour(wks, mslp(26,:,:), lres)
lows27 = gsn_csm_contour(wks, mslp(27,:,:), lres)
lows28 = gsn_csm_contour(wks, mslp(28,:,:), lres)
lows29 = gsn_csm_contour(wks, mslp(29,:,:), lres)
lows30 = gsn_csm_contour(wks, mslp(30,:,:), lres)
lows31 = gsn_csm_contour(wks, mslp(31,:,:), lres)
lows32 = gsn_csm_contour(wks, mslp(32,:,:), lres)
lows33 = gsn_csm_contour(wks, mslp(33,:,:), lres)
lows34 = gsn_csm_contour(wks, mslp(34,:,:), lres)
lows35 = gsn_csm_contour(wks, mslp(35,:,:), lres)
lows36 = gsn_csm_contour(wks, mslp(36,:,:), lres)
lows37 = gsn_csm_contour(wks, mslp(37,:,:), lres)
lows38 = gsn_csm_contour(wks, mslp(38,:,:), lres)
lows39 = gsn_csm_contour(wks, mslp(39,:,:), lres)
lows40 = gsn_csm_contour(wks, mslp(40,:,:), lres)
lows41 = gsn_csm_contour(wks, mslp(41,:,:), lres)
lows42 = gsn_csm_contour(wks, mslp(42,:,:), lres)
lows43 = gsn_csm_contour(wks, mslp(43,:,:), lres)
lows44 = gsn_csm_contour(wks, mslp(44,:,:), lres)
lows45 = gsn_csm_contour(wks, mslp(45,:,:), lres)
lows46 = gsn_csm_contour(wks, mslp(46,:,:), lres)
lows47 = gsn_csm_contour(wks, mslp(47,:,:), lres)
lows48 = gsn_csm_contour(wks, mslp(48,:,:), lres)
lows49 = gsn_csm_contour(wks, mslp(49,:,:), lres)
lows50 = gsn_csm_contour(wks, mslp(50,:,:), lres)

if identify .eq. "on" then
bloop = gsn_csm_contour(wks, circ_calc(:,:), cres)
end if

;********************************************

;overlay(plot,contours0)
;overlay(plot,contours1)
;overlay(plot,contours2)
;overlay(plot,contours3)
;overlay(plot,contours4)
;overlay(plot,contours5)
;overlay(plot,contours6)
;overlay(plot,contours7)
;overlay(plot,contours8)
;overlay(plot,contours9)
;overlay(plot,contours10)
;overlay(plot,contours11)
;overlay(plot,contours12)
;overlay(plot,contours13)
;overlay(plot,contours14)
;overlay(plot,contours15)
;overlay(plot,contours16)
;overlay(plot,contours17)
;overlay(plot,contours18)
;overlay(plot,contours19)
;overlay(plot,contours20)

overlay(plot,lows0)
overlay(plot,lows1)
overlay(plot,lows2)
overlay(plot,lows3)
overlay(plot,lows4)
overlay(plot,lows5)
overlay(plot,lows6)
overlay(plot,lows7)
overlay(plot,lows8)
overlay(plot,lows9)
overlay(plot,lows10)
overlay(plot,lows11)
overlay(plot,lows12)
overlay(plot,lows13)
overlay(plot,lows14)
overlay(plot,lows15)
overlay(plot,lows16)
overlay(plot,lows17)
overlay(plot,lows18)
overlay(plot,lows19)
overlay(plot,lows20)
overlay(plot,lows21)
overlay(plot,lows22)
overlay(plot,lows23)
overlay(plot,lows24)
overlay(plot,lows25)
overlay(plot,lows26)
overlay(plot,lows27)
overlay(plot,lows28)
overlay(plot,lows29)
overlay(plot,lows30)
overlay(plot,lows31)
overlay(plot,lows32)
overlay(plot,lows33)
overlay(plot,lows34)
overlay(plot,lows35)
overlay(plot,lows36)
overlay(plot,lows37)
overlay(plot,lows38)
overlay(plot,lows39)
overlay(plot,lows40)
overlay(plot,lows41)
overlay(plot,lows42)
overlay(plot,lows43)
overlay(plot,lows44)
overlay(plot,lows45)
overlay(plot,lows46)
overlay(plot,lows47)
overlay(plot,lows48)
overlay(plot,lows49)
overlay(plot,lows50)

;overlay(plot,bloop)

;********************************************

tcres = True
tcres@gsMarkerSizeF = 0.017
tcres@gsMarkerColor = "gold"
tcres@gsMarkerOpacityF = 1.0
tcres@gsMarkerIndex = 16
tcres@gsMarkerThicknessF = 1

tc_loc = gsn_add_polymarker(wks, plot, -91.9, 29.3, tcres)

;-------------------------------------------

  mkres               = True
  mkres@gsMarkerIndex = 16        ; filled dot
  mkres@gsMarkerSizeF =  0.017       ; make dot larger
  mkres@gsMarkerColor = "green"

;  dumlow = gsn_add_polymarker(wks,plot,-81.5,18.0,mkres)

;********************************************

draw(plot)
frame(wks)

system("convert "+dir_plot+name+"_"+filefhr+".png -trim +repage "+dir_out+name+"_"+filefhr+".png")
system ("scp "+dir_plot+name+"_"+filefhr+".png abentley@emcrzdm:"+dir_out_web+".")
print("Image: "+dir_out_web+name+"_"+filefhr+".png")
print(" ")

;**********************************************************************************************************
;**********************************************************************************************************
;**********************************************************************************************************

end do          ; end domain

imgcount = imgcount + 1

end do          ; end forecast hour

end if ; if toplot .eq. "yes"

print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end



