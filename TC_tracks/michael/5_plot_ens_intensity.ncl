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

syyyy = 2018
smm = 10
sdd = 8
shh = 0

model = "gefs"		; "gefs", "ec", "ukmet"
TCname = "michael"
dir_out_web = "/home/people/emc/www/htdocs/users/Alicia.Bentley/fv3gfs/retros/images/test/"
type = "mslp"  		; "mslp" or "wind"
endhr = 120

;------------------------------------------------------------

if model .eq. "gefs" then
        number = toint(21)     ; number of members
end if
if model .eq. "ec" then
        number = toint(51)     ; number of members
end if
if model .eq. "cmc" then
        number = toint(21)
end if
if model .eq. "ukmet" then
        number = toint(36)
end if

;------------------------------------------------------------

dir_out = "./"

timeUnits = "hours since 1800-01-01 00:00:00"
sdate = cd_inv_calendar(syyyy,smm,sdd,shh,00,00,timeUnits,0)
;edate = cd_inv_calendar(eyyyy,emm,edd,ehh,00,00,timeUnits,0)

print("sdate: "+ut_string(sdate,""))
;print("edate: "+ut_string(edate,""))
print(" ")

int_date = ut_string(sdate,"%Y%N%D")
;print("int_date: "+int_date)
int_hh = ut_string(sdate,"%H")
;print("int_hh: "+int_hh)

int_time = int_date+int_hh
print("int_time: "+int_time)

name = model+"_intensity_"+type+"_"+int_time
lasthr = 240

;----------------------------------------
; Loops from initalization through fhr
;----------------------------------------

print("lasthr: "+lasthr)
fhr = ispan(0,lasthr,6)
nfhr = dimsizes(fhr)
print("nfhr: "+nfhr)

data = new((/6,number+3,nfhr/),double,9.969209968386869e+36)

;************************************************************************

;lines = 168
;lines_e = 855

; Read in file with ensemble members

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

;print(cyc_arr_temp)

do ens = 0,number-1,1

	print("ens: "+ens)
	iz := ind(cyc_arr_temp .eq. ens)
;	print(iz)
	ens_length = dimsizes(iz)-1

data(0,toint(ens),0:ens_length) = todouble(yyyy_arr_temp(iz))
data(1,toint(ens),0:ens_length) = todouble(mm_arr_temp(iz))
data(2,toint(ens),0:ens_length) = todouble(dd_arr_temp(iz))
data(3,toint(ens),0:ens_length) = todouble(hh_arr_temp(iz))
data(5,toint(ens),0:ens_length) = todouble(cyc_arr_temp(iz))

if type .eq. "mslp" then
	data(4,toint(ens),0:ens_length) = todouble(mslp_arr_temp(iz))
end if

if type .eq. "wind" then
        data(4,toint(ens),0:ens_length) = todouble(wind_arr_temp(iz))
end if

end do ;end ens

;print(data(5,:,:))

;-------------------------------------------------------------------
;-------------------------------------------------------------------

; Read in data from mean and determinisitic file

track_url = "./"
trk_read := asciiread(track_url+model+"_det_mean_"+int_time+"_"+TCname+".csv",-1,"string")
delim = ", "
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
wind_arr_temp := str_get_field(trk_read, 8,delim)
cyc_arr_temp := str_get_field(trk_read, 9,delim)

;print(cyc_arr_temp)

do ens = number,number+1,1

        print("ens: "+ens)
        iz := ind(cyc_arr_temp .eq. ens)
;       print(iz)
        ens_length = dimsizes(iz)-1

data(0,toint(ens),0:ens_length) = todouble(yyyy_arr_temp(iz))
data(1,toint(ens),0:ens_length) = todouble(mm_arr_temp(iz))
data(2,toint(ens),0:ens_length) = todouble(dd_arr_temp(iz))
data(3,toint(ens),0:ens_length) = todouble(hh_arr_temp(iz))
data(5,toint(ens),0:ens_length) = todouble(cyc_arr_temp(iz))

if type .eq. "mslp" then
        data(4,toint(ens),0:ens_length) = todouble(mslp_arr_temp(iz))
end if

if type .eq. "wind" then
        data(4,toint(ens),0:ens_length) = todouble(wind_arr_temp(iz))
end if

;print(data(4,toint(ens),:))
data(4,toint(ens),:) = where((data(4,toint(ens),:) .eq. -2147483648),data@_FillValue,data(4,toint(ens),:))
;print(data(4,toint(ens),:))

end do ;end ens



;print(data(5,:,:))

;-------------------------------------------------------------------
;-------------------------------------------------------------------

; Read in data from Best Track file

track_url = "./"
trk_read := asciiread(track_url+"best_track_"+TCname+".csv",-1,"string")
delim = ", "
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
wind_arr_temp := str_get_field(trk_read, 8,delim)
cyc_arr_temp := str_get_field(trk_read, 9,delim)

;print(cyc_arr_temp)


        print("Calculate initial adjustment...")
        change = data(2,0,0)
;        print("change: "+change)

        date_opts = ind(dd_arr_temp .eq. sdd)
        date_ind = min(date_opts)
;        print(date_ind)

        hour_opts = hh_arr_temp(date_opts)
;        print(hour_opts)
        hour_ind = ind(hour_opts .eq. toint(shh))
;        print(hour_ind)

        adjust = date_ind + hour_ind
;        print("adjust: "+adjust)

	ind_start = adjust

        iz := ind(yyyy_arr_temp .eq. yyyy_arr_temp(0))
;       print(iz)
        ind_end = dimsizes(iz)-1
	print("ind_start: "+ind_start+" ind_end: "+ind_end)

data(0,number+2,0:ind_end-ind_start) = todouble(yyyy_arr_temp(ind_start:ind_end))
data(1,number+2,0:ind_end-ind_start) = todouble(mm_arr_temp(ind_start:ind_end))
data(2,number+2,0:ind_end-ind_start) = todouble(dd_arr_temp(ind_start:ind_end))
data(3,number+2,0:ind_end-ind_start) = todouble(hh_arr_temp(ind_start:ind_end))
data(5,number+2,0:ind_end-ind_start) = number+2

if type .eq. "mslp" then
        data(4,number+2,0:ind_end-ind_start) = todouble(mslp_arr_temp(ind_start:ind_end))
end if

if type .eq. "wind" then
        data(4,number+2,0:ind_end-ind_start) = todouble(wind_arr_temp(ind_start:ind_end))
end if

;print(data(5,:,:))

;-------------------------------------------

print(" ")
print("Successfully got data from files!")
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
res@tiMainString = "Ens. Mems. (light blue); Ens. Mean (blue); Deterministic (red); Best Track (black)"
res@tiMainFontHeightF = 0.012

res@tiYAxisString = "Mean Sea Level Pressure (hPa)"
res@tiXAxisString = "Forecast Hour (h)"
res@tiYAxisFontHeightF = 0.012
res@tiXAxisFontHeightF = 0.012

res@gsnLeftString = "Init: "+ut_string(sdate,"")
res@gsnLeftStringFontHeightF = 0.010
res@gsnLeftStringParallelPosF = 0.02
res@gsnLeftStringOrthogonalPosF = -0.08


if (model .eq. "gefs") .or. (model .eq. "cmc") then
res@xyLineThicknesses = (/5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,11.0,9.0,9.0/)
res@xyLineColors = (/"steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","blue","red","black"/)
end if

if model .eq. "ec" then
if number .eq. 51 then
res@xyLineThicknesses = (/5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,11.0,9.0,9.0/)
res@xyLineColors = (/"steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","blue","red","black"/)
end if

if number .eq. 47 then
res@xyLineThicknesses = (/5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,11.0,9.0,9.0/)
res@xyLineColors = (/"steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","blue","red","black"/)
end if

if number .eq. 42 then
res@xyLineThicknesses = (/5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,11.0,9.0,9.0/)
res@xyLineColors = (/"steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","blue","red","black"/)
end if

end if

if (model .eq. "ukmet") then
res@xyLineThicknesses = (/5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,11.0,9.0,9.0/)
res@xyLineColors = (/"steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","blue","red","black"/)
end if

res@xyDashPattern = 0

res@vpWidthF = 0.6
res@vpHeightF = 0.4

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

if type .eq. "mslp" then
;res@tmYLMode = "Explicit"
;res@tmYLValues = ispan(940,1020,10)
;res@tmYLLabels = ispan(940,1020,10)
res@trYMinF = 920
res@trYMaxF = 1020
end if

if type .eq. "wind" then
;res@tmYLMode = "Explicit"
;res@tmYLValues = ispan(940,1020,10)
;res@tmYLLabels = ispan(940,1020,10)
res@trYMinF = 0
res@trYMaxF = 140
end if

plot = gsn_csm_xy(wks,fhr,data(4,:,:),res)

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
