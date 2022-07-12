;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;;
;;
;; Creates GEFS tracks of TCs
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

TCname = "florence"
model = "ukmet"
num_fcsts = 24

dir_out = "./"
track_url = "./"
filename_mean := model+"_mean_error_"+TCname+".csv"
count = -1

;************************************************************************

; Read in best track file
lines = 68
endvar = lines - 1

track_url = "./"
fileread := asciiread(track_url+"florence_track.csv",(/lines,9/),"float")

yyyy_arr := new(lines,double,-9999999)
mm_arr := new(lines,double,-9999999)
dd_arr := new(lines,double,-9999999)
hh_arr := new(lines,double,-9999999)
rlat_arr := new(lines,float,-9999999)
rlon_arr := new(lines,float,-9999999)
pres_arr := new(lines,double,-9999999)
wind_arr := new(lines,double,-9999999)
cyc_arr := new(lines,double,-9999999)

do timestep = 0,endvar

number = timestep + 1
print("Obtaining line: "+number+" of "+lines)

yyyy = flt2dble(fileread(timestep,0))
mm = flt2dble(fileread(timestep,1))
dd = flt2dble(fileread(timestep,2))
hh = flt2dble(fileread(timestep,3))
pres = decimalPlaces(flt2dble(fileread(timestep,4)),2,True)
rlat = tofloat(fileread(timestep,5))
rlon = tofloat(fileread(timestep,6))
wind = flt2dble(fileread(timestep,7))
cyc = flt2dble(fileread(timestep,8))

yyyy_arr(timestep) = yyyy
mm_arr(timestep) = mm
dd_arr(timestep) = dd
hh_arr(timestep) = hh
pres_arr(timestep) = pres
rlat_arr(timestep) = rlat
rlon_arr(timestep) = rlon
wind_arr(timestep) = wind
cyc_arr(timestep) = cyc

end do    ; end timestep (aka: finding lat/lons to plot)

print(" ")
print("Successfully got Best Track Data!")
print(" ")

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
date_arr := new((/4,toint(lines)/),"double")
outlines := new((/50/),"string")
line_num = 0

printVarSummary(calc_arr)












date = (/"02","03","04","05","06","07","08","09","10","11","12","13"/)       
enddate = dimsizes(date)

hour = (/"00","12"/)                                  
endhour = dimsizes(hour)

do x = 0,enddate-1
	day = date(x)

do y = 0,endhour-1
	hr = hour(y)

	int_time = "201809"+day+hr
	print("int_time: "+int_time)
        print("lines: "+lines)
	print(" ")

        count = toint(count + 1)
	print("Fcst#: "+count)

if model .eq. "ec" then
        fileread_int := asciiread(track_url+model+"_mean_GTS_"+int_time+"_"+TCname+".csv",(/lines,9/),"float")
        fileread_loc := asciiread(track_url+model+"_mean_EEMN_"+int_time+"_"+TCname+".csv",(/lines,9/),"float")
else
	fileread_int := asciiread(track_url+model+"_mean_"+int_time+"_"+TCname+".csv",(/lines,9/),"float")
	fileread_loc := asciiread(track_url+model+"_mean_"+int_time+"_"+TCname+".csv",(/lines,9/),"float")
end if




change = toint(day)
print("change: "+change)

spot = 0




do timestep = 0,lines-1,1

	number = timestep + 1
	print("Obtaining line: "+number+" of "+lines)

	yyyy = flt2dble(fileread_loc(timestep,0))
	mm = flt2dble(fileread_loc(timestep,1))
	dd = flt2dble(fileread_loc(timestep,2))
	hh = flt2dble(fileread_loc(timestep,3))
	pres = decimalPlaces(flt2dble(fileread_int(timestep,4)),2,True)
	rlat = tofloat(fileread_loc(timestep,5))
	rlon = tofloat(fileread_loc(timestep,6))
if model .eq. "ukmet" then
	wind = (flt2dble(fileread_int(timestep,7))*1.94384)   ; convert from m/s to kt
else
	wind = flt2dble(fileread_int(timestep,7))
end if
	ens = flt2dble(fileread_loc(timestep,8))

if day .eq. "02" .and. hr .eq. "00" then
	print("yyyy: "+yyyy+" mm: "+mm+" dd: "+dd+" hh: "+hh+" spot: "+spot)
	date_arr(0,spot) = yyyy 
	date_arr(1,spot) = mm
	date_arr(2,spot) = dd
	date_arr(3,spot) = hh
end if

	print(" ")
	print("timestep: "+timestep)
        print(" ") 
	print("pres: "+pres+" rlat: "+rlat+" rlon: "+rlon+" wind: "+wind+" (Best Track)")

;print("hr: "+hr)

if hr .eq. "00" then
adjust = 5+(4*(change-2)+timestep)
if adjust .le. 67 then
	bpres = pres_arr(5+(4*(change-2))+timestep)
	blat = rlat_arr(5+(4*(change-2))+timestep)
	blon = rlon_arr(5+(4*(change-2))+timestep)
	bwind = wind_arr(5+(4*(change-2))+timestep)
        print("bpres: "+bpres+" blat: "+blat+" blon: "+blon+" bwind: "+bwind+" (Ens. Mean)")
        print(" ")
end if
end if

if hr .eq. "12" then
adjust = 5+2+(4*(change-2)+timestep)
if adjust .le. 67 then
	bpres = pres_arr(5+2+(4*(change-2))+timestep)
	blat = rlat_arr(5+2+(4*(change-2))+timestep)
	blon = rlon_arr(5+2+(4*(change-2))+timestep)
	bwind = wind_arr(5+2+(4*(change-2))+timestep)
        print("bpres: "+bpres+" blat: "+blat+" blon: "+blon+" bwind: "+bwind+" (Ens. Mean)")
        print(" ")
end if
end if

if adjust .le. 67 then
	pres_error = pres-bpres
	wind_error = wind-bwind
	dist_error = gc_latlon(rlat,rlon, blat,blon, 10,4)
	if (blat .eq. rlat) .and. (blon .eq. rlon) then
        	dist_error = 0.0
	end if
end if
if adjust .gt. 67 then
	pres_error := calc_arr@_FillValue
	wind_error := calc_arr@_FillValue
	dist_error := calc_arr@_FillValue
end if



print("pres_error: "+pres_error)
print("wind_error: "+wind_error)
print("dist_error: "+dist_error)

	calc_arr(0,spot,toint(count)) = pres_error
	calc_arr(1,spot,toint(count)) = dist_error
	calc_arr(2,spot,toint(count)) = wind_error
	spot = spot + 1

end do    ; end timestep in mean file

end do ; hh
end do ; dd

print(" ")
print("Calculating average at each forecast hour")

ens_mean = dim_avg_n_Wrap(calc_arr,2)
ens_mean!0 = "var"
ens_mean!1 = "fcst"
printVarSummary(ens_mean)
print(" ")
;print(ens_mean(0,:))

num_arr := new((/lines/),"double")

do l = 0,lines-1
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

        line = date_arr(0,j)+","+date_arr(1,j)+","+date_arr(2,j)+","+date_arr(3,j)+","+ens_mean(0,j)+","+ens_mean(1,j)+","+ens_mean(2,j)+","+fcst_hr+","+num_arr(j)
        print("line: "+line)
        print("line_num: "+line_num)
        outlines(line_num) = line
        line_num = line_num + 1

end do

;-------------------------------------------------------------------

asciiwrite(dir_out+filename_mean, outlines)

print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end
