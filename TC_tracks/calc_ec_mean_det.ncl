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

int_time = 2018091100
TCname = "florence"
model = "ec"

if model .eq. "ec" then
        if (int_time .eq. 2018090100) then
                lines = 1663
        end if
        if (int_time .eq. 2018090200) then
                lines = 1732
        end if
        if (int_time .eq. 2018090300) then
                lines = 1876
        end if
        if (int_time .eq. 2018090400) then
                lines = 1914
        end if
        if (int_time .eq. 2018090500) then
                lines = 1993
        end if
        if (int_time .eq. 2018090600) then
                lines = 2010
        end if
        if (int_time .eq. 2018090700) then
                lines = 1931
        end if
        if (int_time .eq. 2018090800) then
                lines = 1743
        end if
        if (int_time .eq. 2018090900) then
                lines = 1984
        end if
        if (int_time .eq. 2018091000) then
                lines = 1880
        end if
        if (int_time .eq. 2018091100) then
                lines = 1784
        end if
        if (int_time .eq. 2018091200) then
                lines = 1808
        end if
        if (int_time .eq. 2018091300) then
                lines = 1616
        end if
end if

dir_out = "./"
track_url = "./"
fileread := asciiread(track_url+model+"_"+int_time+"_"+TCname+".csv",(/lines,9/),"float")
filename_mean := model+"_mean_det_"+int_time+"_"+TCname+".csv"

calc_arr := new((/4,41,50/),"double")
date_arr := new((/4,41/),"double")
outlines := new((/3000/),"string")
outlines2 := new((/3000/),"string")
prev_ens = -1
line_num = 0

do timestep = 0,lines-1,1

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
ens = flt2dble(fileread(timestep,8))

if ens .ne. prev_ens then
        print("New ensemble!")
        spot = 0
	prev_ens := ens
end if

if ens .eq. 0 then
	print("yyyy: "+yyyy+" mm: "+mm+" dd: "+dd+" hh: "+hh+" spot: "+spot)
	date_arr(0,spot) = yyyy 
	date_arr(1,spot) = mm
	date_arr(2,spot) = dd
	date_arr(3,spot) = hh
end if     ; ens

print("pres: "+pres+" rlat: "+rlat+" rlon: "+rlon+" wind: "+wind+" ens: "+ens)
print(" ")
calc_arr(0,spot,toint(ens)) = pres
calc_arr(1,spot,toint(ens)) = rlat
calc_arr(2,spot,toint(ens)) = rlon
calc_arr(3,spot,toint(ens)) = wind
spot = spot + 1
end do    ; end timestep (aka: finding lat/lons to plot)

print(" ")
print("Lat/Lons successfully collected from file")

ens_mean = dim_avg_n_Wrap(calc_arr,2)
ens_mean!0 = "var"
ens_mean!1 = "fcst"
printVarSummary(ens_mean)

;print(ens_mean(0,:))


do j = 0,41-1,1

        line = date_arr(0,j)+","+date_arr(1,j)+","+date_arr(2,j)+","+date_arr(3,j)+","+ens_mean(0,j)+","+ens_mean(1,j)+","+ens_mean(2,j)+","+ens_mean(3,j)+",1"
        print("line: "+line)
        print("line_num: "+line_num)
        outlines(line_num) = line
        line_num = line_num + 1

end do

;-------------------------------------------------------------------

lines_d = 40
fileread := asciiread("ec_det_"+int_time+"_"+TCname+".csv",(/lines_d,9/),"float")

do timestep = 0,lines_d-1

number = timestep + 1
print("Obtaining line: "+number+" of "+lines_d)

year = flt2dble(fileread(timestep,0))
month = flt2dble(fileread(timestep,1))
day = flt2dble(fileread(timestep,2))
hour = flt2dble(fileread(timestep,3))
mslp = decimalPlaces(flt2dble(fileread(timestep,4)),2,True)
lat = tofloat(fileread(timestep,5))
lon = tofloat(fileread(timestep,6))
wind = flt2dble(fileread(timestep,7))
ensemble = 2

        line = year+","+month+","+day+","+hour+","+mslp+","+lat+","+lon+","+wind+","+ensemble
        print("line: "+line)
        print("line_num: "+line_num)
        outlines(line_num) = line
        line_num = line_num + 1
end do

        asciiwrite(dir_out+filename_mean, outlines)

print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end
