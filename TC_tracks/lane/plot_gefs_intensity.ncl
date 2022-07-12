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

syyyy = 2018
smm = 9
sdd = 13
shh = 0

model = "ec"

TCname = "florence"

lines = 68

if model .eq. "gefs" then
        number = toint(21)     ; number of members
end if
if model .eq. "ec" then
        number = toint(50)     ; number of members
end if
if model .eq. "cmc" then
        number = toint(21)
end if
if model .eq. "ukmet" then
        number = toint(36)
end if

lasthr = 240

dir_out = "./"
dir_out_web = "/home/people/emc/www/htdocs/users/Alicia.Bentley/fv3gfs/retros/images/test/"

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

name = model+"_intensity_"+int_time

;----------------------------------------
; Loops from initalization through fhr
;----------------------------------------

;fhr = ispan(0,384,6)
fhr = ispan(0,lasthr,6)
nfhr = dimsizes(fhr)
print("nfhr: "+nfhr)

data = new((/6,number+3,nfhr/),double,9.969209968386869e+36)

;************************************************************************

if model .eq. "gefs" then
        if (int_time .ge. 2018090100 .and. int_time .le. 2018090300) .or. (int_time .ge. 2018090500 .and. int_time .le. 2018090800) then
                lines_e = 861
        end if
        if int_time .eq. 2018090400 then
                lines_e = 855
        end if
        if int_time .eq. 2018090900 then
                lines_e = 850
        end if
        if int_time .eq. 2018091000 then
                lines_e = 835
        end if
        if int_time .eq. 2018091100 then
                lines_e = 803
        end if
        if int_time .eq. 2018091200 then
                lines_e = 782
        end if
        if int_time .eq. 2018091300 then
                lines_e = 625
        end if
end if
if model .eq. "ec" then
        if (int_time .eq. 2018090100) then
                lines_e = 1663
        end if
        if (int_time .eq. 2018090200) then
                lines_e = 1732
        end if
        if (int_time .eq. 2018090300) then
                lines_e = 1876
        end if
        if (int_time .eq. 2018090400) then
                lines_e = 1914
        end if
        if (int_time .eq. 2018090500) then
                lines_e = 1993
        end if
        if (int_time .eq. 2018090600) then
                lines_e = 2010
        end if
        if (int_time .eq. 2018090700) then
                lines_e = 1931
        end if
        if (int_time .eq. 2018090800) then
                lines_e = 1743
        end if
        if (int_time .eq. 2018090900) then
                lines_e = 1984
        end if
        if (int_time .eq. 2018091000) then
                lines_e = 1880
        end if
        if (int_time .eq. 2018091100) then
                lines_e = 1784
        end if
        if (int_time .eq. 2018091200) then
                lines_e = 1808
        end if
        if (int_time .eq. 2018091300) then
                lines_e = 1616
        end if
end if
if model .eq. "cmc" then
        if (int_time .eq. 2018090200) then
                lines_e = 827
        end if
        if (int_time .eq. 2018090300) then
                lines_e = 845
        end if
        if (int_time .eq. 2018090400) then
                lines_e = 791
        end if
        if (int_time .eq. 2018090500) then
                lines_e = 861
        end if
        if (int_time .eq. 2018090600) then
                lines_e = 858
        end if
        if (int_time .eq. 2018090700) then
                lines_e = 830
        end if
        if (int_time .eq. 2018090800) then
                lines_e = 842
        end if
        if (int_time .eq. 2018090900) then
                lines_e = 848
        end if
        if (int_time .eq. 2018091000) then
                lines_e = 822
        end if
        if (int_time .eq. 2018091100) then
                lines_e = 751
        end if
        if (int_time .eq. 2018091200) then
                lines_e = 689
        end if
        if (int_time .eq. 2018091300) then
                lines_e = 627
        end if
end if
if model .eq. "ukmet" then
        if (int_time .eq. 2018090200) .or. (int_time .eq. 2018091000) then
                lines_e = 1043
        end if
        if (int_time .eq. 2018090300) .or. (int_time .eq. 2018090400) .or. (int_time .eq. 2018090600) .or. (int_time .eq. 2018090700) .or. (int_time .eq. 2018090800) .or. (int_time .eq. 2018090900) then
                lines_e = 1044
        end if
        if (int_time .eq. 2018090500) then
                lines_e = 1042
        end if
        if (int_time .eq. 2018091100) then
                lines_e = 1037
        end if
        if (int_time .eq. 2018091200) then
                lines_e = 1004
        end if
        if (int_time .eq. 2018091300) then
                lines_e = 900
        end if
end if



; Read in file with ensemble members
endvar = lines_e - 1

track_url = "./"
fileread := asciiread(track_url+model+"_"+int_time+"_"+TCname+".csv",(/lines_e,9/),"float")

previous_ens = todouble(-1)

do timestep = 0,endvar

	number = timestep + 1
	print("Obtaining line: "+number+" of "+lines_e)

	yyyy = flt2dble(fileread(timestep,0))
	mm = flt2dble(fileread(timestep,1))
	dd = flt2dble(fileread(timestep,2))
	hh = flt2dble(fileread(timestep,3))
	pres = decimalPlaces(flt2dble(fileread(timestep,4)),2,True)
	ens = flt2dble(fileread(timestep,8))
	print("ens: "+ens)
	print("previous_ens: "+previous_ens)

    if ens .ne. previous_ens then
    	print("New ensemble member!")
    	count = 0
    	previous_ens = ens
    end if 
    print("count: "+count)

	data(0,toint(ens),count) = yyyy
	data(1,toint(ens),count) = mm
	data(2,toint(ens),count) = dd
	data(3,toint(ens),count) = hh
	data(4,toint(ens),count) = pres
	data(5,toint(ens),count) = ens

	count = count + 1

end do    ; end timestep (aka: finding lat/lons to plot)

ens_num = ens
print("ens_num: "+ens_num)

print(" ")
print("MSLP successfully collected from ensemble file")

;print(data(4,4,:))

;************************************************************************

; Read in file with cyclone tracks
if model .eq. "gefs" then
        lines_m = 72
	if int_time .eq. 2018091300 then
		lines_m = 63 
	end if
end if
if model .eq. "ec" then
        lines_m = 81
end if
if model .eq. "cmc" then
        lines_m = 82
	if int_time .eq. 2018091200 then
		lines_m = 57
	end if
        if int_time .eq. 2018091300 then
                lines_m = 60
        end if
end if
if model .eq. "ukmet" then
        lines_m = 50
end if


; Read in file with mean and deterministic
endvar = lines_m - 1

fileread := asciiread(track_url+model+"_mean_det_"+int_time+"_"+TCname+".csv",(/lines_e,9/),"float")

previous_ens = todouble(-1)
ens_spot = 0

do timestep = 0,endvar

	number = timestep + 1
	print("Obtaining line: "+number+" of "+lines_m)

	yyyy = flt2dble(fileread(timestep,0))
	mm = flt2dble(fileread(timestep,1))
	dd = flt2dble(fileread(timestep,2))
	hh = flt2dble(fileread(timestep,3))
	pres = decimalPlaces(flt2dble(fileread(timestep,4)),2,True)
	ens = flt2dble(fileread(timestep,8))
	print("ens: "+ens)
	print("previous_ens: "+previous_ens)

    if ens .ne. previous_ens then
    	print("New ensemble member!")
    	count = 0
    	previous_ens = ens
        ens_spot = ens_spot+1
    end if 
    print("count: "+count)

	data(0,toint(ens_num+ens_spot),count) = yyyy
	data(1,toint(ens_num+ens_spot),count) = mm
	data(2,toint(ens_num+ens_spot),count) = dd
	data(3,toint(ens_num+ens_spot),count) = hh
	data(4,toint(ens_num+ens_spot),count) = pres
	data(5,toint(ens_num+ens_spot),count) = ens

	count = count + 1

end do    ; end timestep (aka: finding lat/lons to plot)

print(" ")
print("MSLP successfully collected from mean/deterministic file")
print(" ")

;print(data(4,22,:))

;************************************************************************

; Read in file with mean and deterministic
endvar = lines - 1

fileread := asciiread(track_url+"florence_track.csv",(/lines,9/),"float")

previous_ens = todouble(-1)

print("sdd: "+sdd)
print("start: "+toint((sdd*4)-4))
print("stop: "+(lines-1))
diff = (toint(lines-1))-(toint((toint(sdd)*4)-4))
print("diff: "+diff)

if ((toint((sdd*4)-4))+41-1) .le. (lines-1) then
off_end = ((toint((sdd*4)-4))+41-1)
else
off_end = lines-1
end if

do timestep = toint((sdd*4)-4),off_end      ;toint(((sdd*4)-4)+(240./6.))

	number = timestep + 1
	print("Obtaining line: "+number+" of "+lines)

	yyyy = flt2dble(fileread(timestep,0))
	mm = flt2dble(fileread(timestep,1))
	dd = flt2dble(fileread(timestep,2))
	hh = flt2dble(fileread(timestep,3))
	pres = decimalPlaces(flt2dble(fileread(timestep,4)),2,True)
	ens = flt2dble(fileread(timestep,8))
	print("ens: "+ens)
	print("previous_ens: "+previous_ens)

    if ens .ne. previous_ens then
    	print("New ensemble member!")
    	count = 0
    	previous_ens = ens
    end if 
    print("count: "+count)

	data(0,toint(ens_num+3),count) = yyyy
	data(1,toint(ens_num+3),count) = mm
	data(2,toint(ens_num+3),count) = dd
	data(3,toint(ens_num+3),count) = hh
	data(4,toint(ens_num+3),count) = pres
	data(5,toint(ens_num+3),count) = toint(ens_num+3)

	count = count + 1

end do    ; end timestep (aka: finding lat/lons to plot)

print(" ")
print("MSLP successfully collected from BEST TRACK file")

;print(data(4,23,:))

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
if ens_num .eq. 49 then
res@xyLineThicknesses = (/5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,11.0,9.0,9.0/)
res@xyLineColors = (/"steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","blue","red","black"/)
end if

if ens_num .eq. 47 then
res@xyLineThicknesses = (/5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,5.0,11.0,9.0,9.0/)
res@xyLineColors = (/"steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","steelblue1","blue","red","black"/)
end if

if ens_num .eq. 42 then
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

endhr = 180
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
res@trYMinF = 920
res@trYMaxF = 1020

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
