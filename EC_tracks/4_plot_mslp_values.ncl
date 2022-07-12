;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;;
;;
;; Plots graph of TC intensity (mslp or wind) from various ensembles
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
type = "emsl"
ECname = "CA_rain"
dir_out_web = "/home/people/emc/www/htdocs/users/Alicia.Bentley/MEG/EC_tracks/"

syyyy = 2018
smm = 11
sdd = 28
shh = 12

eyyyy = 2018
emm = 11
edd = 29
ehh = 18

fcst_hr_change = 12

fyyyy = 2018
fmm = 11
fdd = 25
fhh = 12

lyyyy = 2018
lmm = 11
ldd = 28
lhh = 12

plot_max = 1016
plot_min = 972
;------------------------------------------------------------

dir_out = "./"

timeUnits = "hours since 1800-01-01 00:00:00"
sdate = cd_inv_calendar(syyyy,smm,sdd,shh,00,00,timeUnits,0)
edate = cd_inv_calendar(eyyyy,emm,edd,ehh,00,00,timeUnits,0)

print("sdate: "+ut_string(sdate,""))
print("edate: "+ut_string(edate,""))
print(" ")

time = ispan(toint(sdate),toint(edate),6)
time!0 = "time"

int_date = ut_string(sdate,"%Y%N%D")
;print("int_date: "+int_date)
int_hh = ut_string(sdate,"%H")
;print("int_hh: "+int_hh)

int_time = int_date+int_hh
print("int_time: "+int_time)

name = model+"_intensity_"+type+"_"+ECname

fdate = cd_inv_calendar(fyyyy,fmm,fdd,fhh,00,00,timeUnits,0)
ldate = cd_inv_calendar(lyyyy,lmm,ldd,lhh,00,00,timeUnits,0)
number = toint(((ldate-fdate)/fcst_hr_change)+1)
print("fdate: "+fdate+" | ldate: "+ldate+" | cycles: "+number)

;----------------------------------------
; Loops from initalization through fhr
;----------------------------------------

diff = edate - sdate
nfhr = (diff/6.)+1
print("nfhr: "+nfhr)

data = new((/6,toint(number+1),toint(nfhr)/),double,9.969209968386869e+36)

;************************************************************************

track_url = "./"
trk_read = asciiread(track_url+model+"_fcst_"+type+"_"+ECname+".csv",-1,"string")
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

;print(cyc_arr_temp)

do ens = 0,number-1,1

;	print("ens: "+ens)
	iz := ind(cyc_arr_temp .eq. ens)
;	print(iz)
	ens_length = dimsizes(iz)-1
;	print("ens_length: "+ens_length)

data(0,toint(ens),0:ens_length) = todouble(yyyy_arr_temp(iz))
data(1,toint(ens),0:ens_length) = todouble(mm_arr_temp(iz))
data(2,toint(ens),0:ens_length) = todouble(dd_arr_temp(iz))
data(3,toint(ens),0:ens_length) = todouble(hh_arr_temp(iz))
data(4,toint(ens),0:ens_length) = todouble(mslp_arr_temp(iz))
data(5,toint(ens),0:ens_length) = todouble(cyc_arr_temp(iz))

end do ;end ens

;print(data(5,:,:))

;-------------------------------------------------------------------

; Read in data from Best Track file

track_url = "./"
trk_read := asciiread(track_url+"gfs_anl_"+type+"_"+ECname+".csv",-1,"string")
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
cyc_arr_temp := str_get_field(trk_read, 8,delim)

;print(cyc_arr_temp)

do ens = 0,0,1

;        print("ens: "+ens)
        iz := ind(cyc_arr_temp .eq. 0)
;        print(iz)
        anl_length = dimsizes(iz)-1
;        print("anl_length: "+anl_length)

data(0,number,0:anl_length) = todouble(yyyy_arr_temp(iz))
data(1,number,0:anl_length) = todouble(mm_arr_temp(iz))
data(2,number,0:anl_length) = todouble(dd_arr_temp(iz))
data(3,number,0:anl_length) = todouble(hh_arr_temp(iz))
data(4,number,0:anl_length) = todouble(mslp_arr_temp(iz))
data(5,number,0:anl_length) = todouble(number)

end do ;end ens

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
res@tiMainString = " "             ;"GFS Analysis (black), Forecasts (Early = Blues, Later = Reds)"
res@tiMainFontHeightF = 0.012

res@tiYAxisString = "Mean Sea Level Pressure (hPa)"
res@tiXAxisString = " " 		;"Valid Date"
res@tiYAxisFontHeightF = 0.012
res@tiXAxisFontHeightF = 0.012

res@gsnLeftString = "Model: "+model+" Type: "+type
res@gsnLeftStringFontHeightF = 0.010
res@gsnLeftStringParallelPosF = 0.02
res@gsnLeftStringOrthogonalPosF = -0.08


if number .eq. 7 then
res@xyLineThicknesses = (/8.0,8.0,8.0,8.0,8.0,8.0,8.0,14.0/)
res@xyLineColors = (/"blue","slateblue2","mediumpurple2","mediumorchid2","magenta2","maroon3","red","black"/)
end if

if number .eq. 10 then
res@xyLineThicknesses = (/8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,8.0,14.0/)
res@xyLineColors = (/"blue","slateblue2","mediumpurple2","mediumorchid2","magenta2","maroon3","red","orangered","chocolate1","orange","black"/)
end if

res@xyDashPattern = 0

res@vpWidthF = 0.5
res@vpHeightF = 0.6


res@tmXBMode = "Explicit"
res@tmXBValues = time
res@trXMaxF = edate
res@trXMinF = sdate
res@tmXBLabelAngleF = 90

labels = new((/toint(nfhr)/),string,9.969209968386869e+36)
place = -1
do cdate = sdate,edate,6
	place = place + 1	
	labels(place) = ut_string(cdate,"%HZ %d %c")
end do
print(labels)
res@tmXBLabels = labels




res@tmXBLabelFontHeightF = 0.012
res@tmYLLabelFontHeightF = 0.012

res@tmXMajorGrid= True
res@tmXMajorGridThicknessF = 1.0
res@tmXMajorGridLineDashPattern = 2
res@tmXMajorGridLineColor = "grey30"

res@tmYMajorGrid= True
res@tmYMajorGridThicknessF = 1.0
res@tmYMajorGridLineDashPattern = 2
res@tmYMajorGridLineColor = "grey30"

res@trYMaxF = plot_max
res@trYMinF = plot_min

;fhr = ispan(0,9,1)

plot = gsn_csm_xy(wks,time,data(4,:,:),res)

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
