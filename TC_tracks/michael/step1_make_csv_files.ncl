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

int_time = "2018091300"

dir_out = "./"
filename = "ec_"+int_time+"_florence.csv"

line_num = 0
outlines := new((/3000/),"string")

do ens = 0,50,1   				; loop through all ensemble members

	if (ens .eq. 0) then
	    mem = "EC00"
	end if

	if (ens .ge. 1 .and. ens .le. 9) then
		mem = "EN0"+ens
	end if

	if (ens .ge. 10 .and. ens .le. 25) then
		mem = "EN"+ens
	end if
  
        if (ens .ge. 26 .and. ens .le. 34) then
                mem = "EP0"+(ens-25)
        end if

        if (ens .ge. 35 .and. ens .le. 50) then
                mem = "EP"+(ens-25)
        end if

	print("mem: "+mem)

	atcf_output := get_atcf("aal062018",mem,int_time,True)

;	printVarSummary(atcf_output)
	;print(atcf_output(0,:))

	do i = 0,dimsizes(atcf_output(0,:))-1        ; loop through all times in this ensemble member

   		time = atcf_output(0,i)
   		time@units = "hours since 1800-01-01 00:00:00"
   		utc_date = cd_calendar(time, 0)

   		year   = tointeger(utc_date(:,0))    ; Convert to integer for
   		month  = tointeger(utc_date(:,1))    ; use sprinti 
   		day    = tointeger(utc_date(:,2))
   		hour   = tointeger(utc_date(:,3))
   		
   		mslp = atcf_output(1,i)
   		lat = atcf_output(2,i)
   		lon = atcf_output(3,i)
   		wind = atcf_output(4,i)
   		ensemble = ens
   
        line = year+","+month+","+day+","+hour+","+mslp+","+lat+","+lon+","+wind+","+ensemble
;   		print("line: "+line)
   		
   		if ens .le. 50 then
   			print("line_num: "+line_num)
			outlines(line_num) = line
			line_num = line_num + 1
		end if
   
	end do
	
end do

        line_num_final = line_num
        print("line_num_final: "+line_num_final)
        asciiwrite(dir_out+filename, outlines)

print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end
