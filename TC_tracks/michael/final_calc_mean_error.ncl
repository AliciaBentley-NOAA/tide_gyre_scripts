;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;;
;;
;; Calculates average ensemble mean track error (11/14/2018)
;;
;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
load "./get_atcf_output.ncl"
;************************************************************************

begin

print(" ")
print("**************")
print(" START SCRIPT ")
print("**************")
print(" ")

TCname = "michael"
model = "gefs"
num_fcsts = 6

date = (/"08","09","10"/)
enddate = dimsizes(date)

hour = (/"00","12"/)
endhour = dimsizes(hour)

;----------------------------------------------------------------------

dir_out = "./"
track_url = "./"
filename_mean := model+"_mean_error_"+TCname+".csv"
count = -1

;************************************************************************

; Read in best track file

btrack_url = "./"
btrk_read = asciiread(btrack_url+"best_track_"+TCname+".csv",-1,"string")

delim = ", "
nfields := str_fields_count(btrk_read, delim)
;print("nfields: "+nfields)

print("Obtaining data from file of unknown length...")

yyyy_arr_temp := str_get_field(btrk_read, 1, delim)
mm_arr_temp := str_get_field(btrk_read, 2, delim)
dd_arr_temp := str_get_field(btrk_read, 3, delim)
hh_arr_temp := str_get_field(btrk_read, 4, delim)
mslp_arr_temp := str_get_field(btrk_read, 5, delim)
rlat_arr_temp := str_get_field(btrk_read, 6, delim)
rlon_arr_temp := str_get_field(btrk_read, 7, delim)
wind_arr_temp := str_get_field(btrk_read, 8,delim)
cyc_arr_temp := str_get_field(btrk_read, 9,delim)

;printVarSummary(yyyy_arr_temp)

iz := ind(yyyy_arr_temp .eq. 2018)
;print(iz)

yyyy_arr := todouble(yyyy_arr_temp(iz))
mm_arr := todouble(mm_arr_temp(iz))
dd_arr := todouble(dd_arr_temp(iz))
hh_arr := todouble(hh_arr_temp(iz))
pres_arr := todouble(mslp_arr_temp(iz))
rlat_arr := todouble(rlat_arr_temp(iz))
rlon_arr := todouble(rlon_arr_temp(iz))
wind_arr := todouble(wind_arr_temp(iz))
cyc_arr := todouble(cyc_arr_temp(iz))

;print(cyc_arr)

print("Lat/Lons successfully collected from Best Track!")

;************************************************************************

if model .eq. "ec" then
    lines = 41
end if
if model .eq. "ukmet" then
    lines = 29
end if
if model .eq. "cmc" then
    lines = 41
end if
if model .eq. "gefs" then
    lines = 41
end if

calc_arr := new((/3,toint(lines),toint(num_fcsts)/),"double")
fcst_error_arr := new((/3,toint(num_fcsts)/),"double")
date_arr := new((/4,toint(lines)/),"double")
outlines := new((/50/),"string")
line_num = 0

printVarSummary(calc_arr)

;-----------------------------------------------------------------------

do x = 0,enddate-1
	day = date(x)

do y = 0,endhour-1
	hr = hour(y)

	int_time = "201810"+day+hr
	print("int_time: "+int_time)
        print("lines: "+lines)
	print(" ")
        count = toint(count + 1)
	print("Fcst#: "+count)

;if model .eq. "ec" then
;        fileread_int := asciiread(track_url+model+"_mean_GTS_"+int_time+"_"+TCname+".csv",(/lines,9/),"float")
;        fileread_loc := asciiread(track_url+model+"_mean_EEMN_"+int_time+"_"+TCname+".csv",(/lines,9/),"float")
;else
;	fileread_int := asciiread(track_url+model+"_mean_"+int_time+"_"+TCname+".csv",(/lines,9/),"float")
;	fileread_loc := asciiread(track_url+model+"_mean_"+int_time+"_"+TCname+".csv",(/lines,9/),"float")
;end if

;************************************************************************

; Read in file with ensemble mean track

track_url = "./"
fileread_int := asciiread(track_url+model+"_mean_"+int_time+"_"+TCname+".csv",-1,"string")
fileread_loc := asciiread(track_url+model+"_mean_"+int_time+"_"+TCname+".csv",-1,"string")

delim = ", "
nfields := str_fields_count(fileread_loc, delim)
;print("nfields: "+nfields)

print("Obtaining data from file of unknown length...")

yyyy_arr_temp := str_get_field(fileread_loc, 1, delim)
mm_arr_temp := str_get_field(fileread_loc, 2, delim)
dd_arr_temp := str_get_field(fileread_loc, 3, delim)
hh_arr_temp := str_get_field(fileread_loc, 4, delim)
mslp_arr_temp := str_get_field(fileread_int, 5, delim)
rlat_arr_temp := str_get_field(fileread_loc, 6, delim)
rlon_arr_temp := str_get_field(fileread_loc, 7, delim)
wind_arr_temp := str_get_field(fileread_int, 8,delim)
cyc_arr_temp := str_get_field(fileread_loc, 9,delim)

iz := ind(yyyy_arr_temp .eq. 2018)
;print(iz)

tyyyy_arr := todouble(yyyy_arr_temp(iz))
tmm_arr := todouble(mm_arr_temp(iz))
tdd_arr := todouble(dd_arr_temp(iz))
thh_arr := todouble(hh_arr_temp(iz))
tpres_arr := todouble(mslp_arr_temp(iz))
trlat_arr := todouble(rlat_arr_temp(iz))
trlon_arr := todouble(rlon_arr_temp(iz))
twind_arr := todouble(wind_arr_temp(iz))
tcyc_arr := todouble(cyc_arr_temp(iz))

;print(tdd_arr)

print("Lat/Lons successfully collected from mean file")

;*********************************************************
;*********************************************************

bt_length = dimsizes(dd_arr)
;print("bt_length: "+bt_length)

endvar = dimsizes(tdd_arr)-1
print("endvar: "+endvar)

spot = 0

;--------------------------

do timestep = 0,endvar,1

	number = timestep + 1
	print("timestep: "+timestep)

	yyyy = tyyyy_arr(timestep)
	mm = tmm_arr(timestep)
	dd = tdd_arr(timestep)
	hh = thh_arr(timestep)
	pres = tpres_arr(timestep)
	rlat = trlat_arr(timestep)
	rlon = trlon_arr(timestep)
	ens = tcyc_arr(timestep)

if model .eq. "ukmet" then
	wind = (twind_arr(timestep)*1.94384)   ; convert from m/s to kt
else
	wind = twind_arr(timestep)
end if

if (timestep .eq. 0) then
	print("Calculate initial adjustment...")
	change = toint(day)
;	print("change: "+change+" toint(date(x)): "+toint(date(x)))

        date_opts = ind(dd_arr .eq. toint(date(x)))
	date_ind = min(date_opts)
;	print(date_ind)	

	hour_opts = hh_arr(date_opts)
;	print(hour_opts)
	hour_ind = ind(hour_opts .eq. toint(hour(y)))
;	print(hour_ind)

	adjust = date_ind + hour_ind
	print("adjust: "+adjust)
else
	adjust = adjust + 1
        print("adjust: "+adjust+" bt_length-1: "+(bt_length-1))
end if

;--------------------------------------------------------

print("day: "+day+" "+date(x)+" hr: "+hour(0))
if day .eq. date(0) .and. hr .eq. hour(0) then
	print("yyyy: "+yyyy+" mm: "+mm+" dd: "+dd+" hh: "+hh+" spot: "+spot)
	date_arr(0,spot) = yyyy 
	date_arr(1,spot) = mm
	date_arr(2,spot) = dd
	date_arr(3,spot) = hh
end if

	print("pres: "+pres+" rlat: "+rlat+" rlon: "+rlon+" wind: "+wind+" (Ens. Mean)")

if (adjust .le. bt_length-1) then
	bpres = pres_arr(adjust)
	blat = rlat_arr(adjust)
	blon = rlon_arr(adjust)
	bwind = wind_arr(adjust)
        print("bpres: "+bpres+" blat: "+blat+" blon: "+blon+" bwind: "+bwind+" (Best Track)")
end if

if (adjust .le. bt_length-1) then
	pres_error = pres-bpres
	wind_error = wind-bwind
	dist_error = gc_latlon(rlat,rlon, blat,blon, 10,4)
	if (blat .eq. rlat) .and. (blon .eq. rlon) then
        	dist_error = 0.0
	end if
end if
if (adjust .gt. bt_length-1) then
	pres_error := calc_arr@_FillValue
	wind_error := calc_arr@_FillValue
	dist_error := calc_arr@_FillValue
end if

print("pres_error: "+pres_error)
print("dist_error: "+dist_error)
print("wind_error: "+wind_error)

	calc_arr(0,spot,toint(count)) = pres_error
	calc_arr(1,spot,toint(count)) = dist_error
	calc_arr(2,spot,toint(count)) = wind_error
	spot = spot + 1
	print(" ")

end do    ; end timestep in mean file

print("Finished that particular forecast!")

fcst_avg_error = dim_avg_n_Wrap(calc_arr(:,:,count),1)
;print("fcst_avg_error: "+fcst_avg_error)
fcst_error_arr(:,count) = fcst_avg_error

end do ; hh
end do ; dd

;--------------------------------------------------

print(" ")
print("Calculating average at each forecast hour")

ens_mean = dim_avg_n_Wrap(calc_arr,2)
ens_mean!0 = "var"
ens_mean!1 = "fcst"
printVarSummary(ens_mean)
print(" ")
;print(ens_mean(0,:))

num_arr := new((/lines/),"double")

do l = 0,lines-1,1
	howmany = 0
	do n = 0,num_fcsts-1,1
		if(.not.ismissing(calc_arr(0,l,n)))
			howmany = howmany + 1
		end if		
	end do
	num_arr(l) = howmany
end do

print(num_arr)



do j = 0,lines-1,1
	fcst_hr = (6*j)

        line = date_arr(0,j)+", "+date_arr(1,j)+", "+date_arr(2,j)+", "+date_arr(3,j)+", "+ens_mean(0,j)+", "+ens_mean(1,j)+", "+ens_mean(2,j)+", "+fcst_hr+", "+num_arr(j)
        print("line: "+line)
        print("line_num: "+line_num)
        outlines(line_num) = line
        line_num = line_num + 1

end do

;-------------------------------------------------------------------

asciiwrite(dir_out+filename_mean, outlines)

print(fcst_error_arr(1,:))
print("^^^Avergae forecast error for each run ("+model+")^^^")


print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end
