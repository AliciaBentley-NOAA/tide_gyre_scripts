;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;;
;;
;; Plot graph of GEFS TC intensity
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

TCname = "michael"
type = "wind"   	;dist,mslp,wind
lasthr = 72
dir_out_web = "/home/people/emc/www/htdocs/users/Alicia.Bentley/fv3gfs/retros/images/michael/"

;------------------------------------------------

lines = toint((lasthr/6)+1)
print("lines: "+lines)
mod_num = -1
dir_out = "./"
name = "ens_mean_"+type+"_error_comp"

if type .eq. "mslp" then
	spot = 0
end if
if type .eq. "dist" then
        spot = 1
end if
if type .eq. "wind" then
        spot = 2
end if

text = new(lines,graphic)

;------------------------------------------------

mean_arr := new((/4,5,toint(lines)/),"double")



mods = (/"gefs","ec","ukmet"/)
endmods = dimsizes(mods)

do x = 0,endmods-1
        model = mods(x)
	mod_num = mod_num + 1

track_url = "./"
fileread := asciiread(track_url+model+"_mean_error_"+TCname+".csv",-1,"string")
delim = ", "

print("Obtaining data from file of unknown length...")

pres_arr_temp = str_get_field(fileread, 5, delim)
dist_arr_temp = str_get_field(fileread, 6, delim)
wind_arr_temp = str_get_field(fileread, 7, delim)
fcst_arr_temp = str_get_field(fileread, 8, delim)
count_arr_temp = str_get_field(fileread, 9, delim)

iz = ispan(0,lines-1,1)
;print("iz: "+iz)

mean_arr(mod_num,0,:) = todouble(pres_arr_temp(iz))
mean_arr(mod_num,1,:) = todouble(dist_arr_temp(iz))
mean_arr(mod_num,2,:) = todouble(wind_arr_temp(iz))
mean_arr(mod_num,3,:) = todouble(fcst_arr_temp(iz))
mean_arr(mod_num,4,:) = todouble(count_arr_temp(iz))

print(mean_arr(mod_num,4,:))

print(" ")
print("Successfully got Mean Error Data!")
print(" ")

end do ; end x






;----------------------------------------
; Loops from initalization through fhr
;----------------------------------------

fhr = ispan(0,lasthr,6)
nfhr = dimsizes(fhr)
print("nfhr: "+nfhr)

data = mean_arr						;new((/6,number+3,nfhr/)

print(" ")
print("Plotting plumes now...")
print(" ")

;-------------------------------------------

;==============================================
; Create Shaded Map
;==============================================

wks_type = "png"

wks_type@wkWidth = 1600
wks_type@wkHeight = 1600

wks = gsn_open_wks(wks_type,dir_out+name)
;**********************************************

res = True
res@tiMainString = "GEFS mean (blue), ECMWF mean (red), UKMET mean (yellow)"
res@tiMainFontHeightF = 0.012

res@tiXAxisString = "Forecast Hour (h)"
res@tiYAxisFontHeightF = 0.012
res@tiXAxisFontHeightF = 0.012

res@gsnLeftString = "Includes all 00Z and 12Z forecasts (10/8/18-10/10/18)"
res@gsnLeftStringFontHeightF = 0.010
res@gsnLeftStringParallelPosF = 0.02
res@gsnLeftStringOrthogonalPosF = -0.08


res@xyLineThicknesses = (/11.0,11.0,11.0,11.0/)
res@xyLineColors = (/"blue","red","gold","steelblue1"/)


res@xyDashPattern = 0

res@vpWidthF = 0.6
res@vpHeightF = 0.4

endhr = lasthr
res@tmXBMode = "Explicit"
res@tmXBValues = ispan(0,endhr,12)
res@tmXBLabels = ispan(0,endhr,12)
;res@tmXBTickEndF = endhr
res@trXMaxF = endhr

res@tmXBLabelFontHeightF = 0.012
res@tmYLLabelFontHeightF = 0.012

res@tmXMajorGrid= True
res@tmXMajorGridThicknessF = 1.0
res@tmXMajorGridLineDashPattern = 2
res@tmXMajorGridLineColor = "grey60"

res@tmYMajorGrid= True
res@tmYMajorGridThicknessF = 1.0
res@tmYMajorGridLineDashPattern = 2
res@tmYMajorGridLineColor = "grey60"

;res@tmYLMode = "Explicit"
;res@tmYLValues = ispan(940,1020,10)
;res@tmYLLabels = ispan(940,1020,10)

if type .eq. "mslp" then
res@trYMinF = 0.
res@trYMaxF = 40.
res@tiYAxisString = "Mean Sea Level Pressure Error (hPa)"
end if

if type .eq. "wind" then
res@trYMinF = -50.
res@trYMaxF = 0.
res@tiYAxisString = "Wind Speed (Vmax) Error (kt)"
end if

if type .eq. "dist" then
res@trYMinF = 0.
res@trYMaxF = 500.
res@tiYAxisString = "Track Error (km)"
end if

plot = gsn_csm_xy(wks,fhr,data(:,spot,:),res)

;---------------------------------------

  do pamela = 0,lines-1,1
	cur_count = tostring(toint(data(0,4,pamela)))
	print("cur_count: "+cur_count)
	res@txFontHeightF = 0.012
        res@txFontColor = "black"
	text(pamela) = gsn_add_text(wks,plot,cur_count,fhr(pamela),data(0,spot,pamela),res)
;	print("fhr(pamela): "+fhr(pamela))
  end do

 ;----------------------------------------

system("convert -trim "+name+".png "+name+".png")
system ("scp "+name+".png abentley@emcrzdm:"+dir_out_web+".")

;***************************************************************
;***************************************************************
;***************************************************************

print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end
