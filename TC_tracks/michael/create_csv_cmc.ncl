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
TCname = "florence"
model = "cmc"

dir_out = "./"
filename = model+"_"+int_time+"_"+TCname+".csv"
filename_mean = model+"_mean_det_"+int_time+"_"+TCname+".csv"

line_num = 0
line_num2 = 0
outlines := new((/3000/),"string")
outlines2 := new((/3000/),"string")

do ens = 1,2,1   				; loop through all ensemble members

        if (ens .eq. 1) then 
            mem = "CEMN"
        end if  

        if (ens .eq. 2) then
            mem = "CMC"
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
   		
   		if ens .ge. 20 then
   			print("line_num: "+line_num)
			outlines(line_num) = line
			line_num = line_num + 1
		end if

                if ens .le. 2 then
                        print("line_num2: "+line_num2)
                        outlines2(line_num2) = line
                        line_num2 = line_num2 + 1
                end if

   
	end do
	
end do

        line_num_final = line_num
	print(" ")
        print("line_num2: "+line_num2)
;        asciiwrite(dir_out+filename, outlines)
        asciiwrite(dir_out+filename_mean, outlines2)


print(" ")
print("**************")
print(" END SCRIPT ")
print("**************")
print(" ")

end
