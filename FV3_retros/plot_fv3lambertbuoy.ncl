load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

;; domain definitions
;; new domains could be defined by adding entries in the next 5 lines
  minlatlist=(/15.0,35.0,25.0,31.0,40.0,25.5,35.0,42.0,41.0,34.0,40.0,34.0,24.5,12.5,10,20,1,-40,15/)
  maxlatlist=(/60.0,75.0,50.0,43.0,50.0,37.5,44.0,50.0,49.5,43.0,48.0,42.5,35.0,35,27,47.5,60,-1,62.5/)
  minlonlist=(/-135.0,160.0,-120,-125.0,-125.0,-108.0,-108.0,-110.0,-97.0,-97.0,-81.0,-86.0,-92.0,-105,-81,-95,110,137.5,-167.5/)
  maxlonlist=(/-60.0,250.0,-72.5,-105.0,-107.0,-90.0,-92.0,-95.0,-80.5,-83.0,-66.5,-72.0,-76.0,-72.5,-55,-57.5,179,192.5,-115/)
  regionlist=(/"us","ak","uszoom","sw","nw","t","cp","np","mw","ov","ne","ma","se","gom","pr","nwatl","wpac","spac","epac"/)
  if (isdefined("scriptregion")) then
     if (scriptregion .eq. "new")
        print("New domain requested. Script will fail if the following variables are not defined with command line arguments: regionname, minlat, minlon, maxlat, maxlon.")
        scriptregion=regionname
     else
        print("domain defined on command line")
        scriptregion=str_lower(scriptregion)
     end if
  else
     scriptregion="uszoom"
  end if
  do c=0,dimsizes(regionlist)-1
    if (regionlist(c).eq.scriptregion) then
      minlat=minlatlist(c)
      minlon=minlonlist(c)
      maxlat=maxlatlist(c)
      maxlon=maxlonlist(c)
    end if
  end do

  if (scriptregion .eq. "ak" .or. scriptregion .eq. "pr" .or. scriptregion .eq. "epac" .or. scriptregion .eq. "wpac" .or. scriptregion .eq. "spac")
     CONUS_dom = False
     NA_dom = False
  else if (scriptregion .eq. "us" .or. scriptregion .eq. "nwatl" .or. scriptregion .eq. "gom")
     NA_dom = True
     CONUS_dom = False
  else
     CONUS_dom = True
     NA_dom = False
  end if
  end if
  CONUS_dom = False

  scriptyear=toint(str_get_cols(scriptyyyymmddhh,0,3))
  scriptmonth=toint(str_get_cols(scriptyyyymmddhh,4,5))
  scriptday=toint(str_get_cols(scriptyyyymmddhh,6,7))
  scripthour=toint(str_get_cols(scriptyyyymmddhh,8,9))
  timeunits="hours since 1800-01-01 00:00"
  datemodel=ut_inv_calendar(scriptyear,scriptmonth,scriptday,scripthour,0,0,timeunits,0)
  datemodel@units=timeunits


;;; define start and end dates for changing GFS tarfile naming conventions on HPSS
  gfs_sdate = cd_inv_calendar(2016,5,10,00,00,00,timeunits,0)      ; Specify start date of date range (sdate)
  gfs_edate = cd_inv_calendar(2017,7,20,00,00,00,timeunits,0)      ; Specify end date of date range (edate)

  if (datemodel .ge. gfs_sdate) .and. (datemodel .le. gfs_edate) then
        print("idate is inside the date range")
        gfstar = "com2_gfs_prod_gfs"
  else if (datemodel .lt. gfs_sdate) then
        print("idate is before the start of the date range")
        gfstar = "com_gfs_prod_gfs"
  else if (datemodel .gt. gfs_edate) then
        print("idate is after the end of the date range")
        gfstar = "gpfs_hps_nco_ops_com_gfs_prod_gfs" 
  end if
  end if
  end if


;;; define start and end dates of real-time/retro streams so HPSS directories are named correctly
  realtime_sdate = cd_inv_calendar(2018,5,25,18,00,00,timeunits,0)      ; Specify start date of date range (sdate)

  retro1_sdate  = cd_inv_calendar(2017,11,25,00,00,00,timeunits,0)      ; Specify start date of date range (sdate)
  retro1_edate = cd_inv_calendar(2018,05,31,00,00,00,timeunits,0)      ; Specify end date of date range (edate)

  retro2a_sdate = cd_inv_calendar(2017,5,25,00,00,00,timeunits,0)      ; Specify start date of date range (sdate)
  retro2a_edate = cd_inv_calendar(2017,8,02,00,00,00,timeunits,0)      ; Specify end date of date range (edate)

  retro2b_sdate = cd_inv_calendar(2017,8,02,00,00,00,timeunits,0)      ; Specify start date of date range (sdate)
  retro2b_edate = cd_inv_calendar(2017,11,09,00,00,00,timeunits,0)      ; Specify end date of date range (edate)

  retro3_sdate = cd_inv_calendar(2016,11,25,00,00,00,timeunits,0)      ; Specify start date of date range (sdate)
  retro3_edate = cd_inv_calendar(2017,5,31,00,00,00,timeunits,0)      ; Specify end date of date range (edate)

  retro4a_sdate = cd_inv_calendar(2016,5,22,00,00,00,timeunits,0)      ; Specify start date of date range (sdate)
  retro4a_edate = cd_inv_calendar(2016,8,17,00,00,00,timeunits,0)      ; Specify end date of date range (edate)

  retro4b_sdate = cd_inv_calendar(2016,8,17,00,00,00,timeunits,0)      ; Specify start date of date range (sdate)
  retro4b_edate = cd_inv_calendar(2016,11,26,00,00,00,timeunits,0)      ; Specify end date of date range (edate)

  retro5_sdate = cd_inv_calendar(2015,11,25,00,00,00,timeunits,0)      ; Specify start date of date range (sdate)
  retro5_edate = cd_inv_calendar(2016,5,31,00,00,00,timeunits,0)      ; Specify end date of date range (edate)

  retro6_sdate = cd_inv_calendar(2015,5,3,00,00,00,timeunits,0)      ; Specify start date of date range (sdate)
  retro6_edate = cd_inv_calendar(2015,11,28,00,00,00,timeunits,0)      ; Specify end date of date range (edate)


  if (datemodel .ge. realtime_sdate) then
     archive_dir = "/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_C/Q2FY19/prfv3rt1"
     WCOSS_dir   = "/gpfs/hps3/ptmp/emc.glopara/ROTDIRS/prfv3rt1"

  else if (datemodel .ge. retro1_sdate) .and. (datemodel .le. retro1_edate) then
     archive_dir = "/NCEPDEV/emc-global/5year/Fanglin.Yang/WCOSS_DELL_P3/Q2FY19/fv3q2fy19retro1"
     WCOSS_dir   = "/gpfs/dell3/ptmp/Fanglin.Yang/fv3q2fy19retro1"

  else if (datemodel .ge. retro2a_sdate) .and. (datemodel .le. retro2a_edate) then
     archive_dir = "/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_C/Q2FY19/fv3q2fy19retro2"
     WCOSS_dir   = "/gpfs/hps3/ptmp/emc.glopara/fv3q2fy19retro2"

  else if (datemodel .ge. retro2b_sdate) .and. (datemodel .le. retro2b_edate) then
     archive_dir = "/NCEPDEV/emc-global/5year/Fanglin.Yang/WCOSS_DELL_P3/Q2FY19/fv3q2fy19retro2"
     WCOSS_dir   = "/gpfs/dell2/ptmp/Fanglin.Yang/fv3q2fy19retro2"

  else if (datemodel .ge. retro3_sdate) .and. (datemodel .le. retro3_edate) then
     archive_dir = "/NCEPDEV/emc-global/5year/Fanglin.Yang/WCOSS_DELL_P3/Q2FY19/fv3q2fy19retro3"
     WCOSS_dir   = "/gpfs/dell3/ptmp/Fanglin.Yang/fv3q2fy19retro3"

  else if (datemodel .ge. retro4a_sdate) .and. (datemodel .le. retro4a_edate) then
     archive_dir = "/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_C/Q2FY19/fv3q2fy19retro4"
     WCOSS_dir   = "/gpfs/hps3/ptmp/emc.glopara/fv3q2fy19retro4"

  else if (datemodel .ge. retro4b_sdate) .and. (datemodel .le. retro4b_edate) then
     archive_dir = "/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_DELL_P3/Q2FY19/fv3q2fy19retro4"
     WCOSS_dir   = "/gpfs/dell2/ptmp/emc.glopara/fv3q2fy19retro4"

  else if (datemodel .ge. retro5_sdate) .and. (datemodel .le. retro5_edate) then
     archive_dir = "/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_DELL_P3/Q2FY19/fv3q2fy19retro5"
     WCOSS_dir   = "/gpfs/dell3/ptmp/emc.glopara/fv3q2fy19retro5"

  else if (datemodel .ge. retro6_sdate) .and. (datemodel .le. retro6_edate) then
     archive_dir = "/NCEPDEV/emc-global/5year/emc.glopara/WCOSS_DELL_P3/Q2FY19/fv3q2fy19retro6"
     WCOSS_dir   = "/gpfs/dell3/ptmp/emc.glopara/fv3q2fy19retro6"

  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if

;;; check to see if starting forecast hour was defined with command line argument
  if (isdefined("fhr_start")) then
     print("starting forecast defined on command line")
     fhrb = toint(fhr_start)
     startdate1=datemodel+fhrb
     startdate1@units=timeunits
     startints=ut_calendar(startdate1,0)
     datestart=ut_inv_calendar(toint(startints(:,0)),toint(startints(:,1)),toint(startints(:,2)),toint(startints(:,3)),0,0,timeunits,0)
  else
     datestart=ut_inv_calendar(scriptyear,scriptmonth,scriptday,scripthour,0,0,timeunits,0)
  end if

;;; check to see if ending forecast hour was defined with command line argument
  if (isdefined("fhr_end")) then
     print("ending forecast defined on command line")
     fhre = toint(fhr_end)
  else
     fhre=24
  end if

  enddate1=datestart+fhre
  enddate1@units=timeunits
  endints=ut_calendar(enddate1,0)

  dateend=ut_inv_calendar(toint(endints(:,0)),toint(endints(:,1)),toint(endints(:,2)),toint(endints(:,3)),0,0,timeunits,0)
  datemodel@units=timeunits

;;; check to see if forecast hour increment was defined with command line argument
  if (isdefined("fhr_inc")) then
     print("forecast hour increment defined on command line")
     fhri = toint(fhr_inc)
  else
     fhri=6
  end if

  fdates=ispan(toint(datestart),toint(dateend),fhri)
  fhours=ispan(toint(datestart)-toint(datemodel),toint(dateend)-toint(datemodel),fhri)


  do h=0,dimsizes(fdates)-1
    ;print((/fhours(h)/))
    thisdate=fdates(h)
    thisdate@units=timeunits
    modelstrings=tostring(ut_calendar(thisdate,-3))
    ms=tostring(ut_calendar(datemodel,-3))
    ;model date
    yearm=str_get_cols(ms,0,3)
    monthm=str_get_cols(ms,4,5)
    daym=str_get_cols(ms,6,7)
    hourm=str_get_cols(ms,8,9)
    mdhm=str_get_cols(ms,4,9)
    ymdm=str_get_cols(ms,0,7)
    ;date of forecast hour
    year=str_get_cols(modelstrings,0,3)
    month=str_get_cols(modelstrings,4,5)
    day=str_get_cols(modelstrings,6,7)
    hour=str_get_cols(modelstrings,8,9)
    mdh=str_get_cols(modelstrings,4,9)
    ymd=str_get_cols(modelstrings,0,7)
    monthind=toint(month)
    months=(/"","January","February","March","April","May","June","July","August","September","October","November","December"/)
    months=(/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)


;;;;; look for FV3GFS forecast file on WCOSS...
;;;;; if not found, look for file in CWD.
;;;;; if not found, pull file from HPSS.
;   parafile="/gpfs/hps3/ptmp/emc.glopara/ROTDIRS/prfv3rt1/gfs."+ymdm+"/"+hourm+"/gfs.t"+hourm+"z.pgrb2.0p25.f"+sprinti("%0.3i",fhours(h))+".grib2"
    parafile=WCOSS_dir+"/gfs."+ymdm+"/"+hourm+"/gfs.t"+hourm+"z.pgrb2.0p25.f"+sprinti("%0.3i",fhours(h))

    if (isfilepresent(parafile)) then
;      para=addfile("/gpfs/hps3/ptmp/emc.glopara/ROTDIRS/prfv3rt1/gfs."+ymdm+"/"+hourm+"/gfs.t"+hourm+"z.pgrb2.0p25.f"+sprinti("%0.3i",fhours(h))+".grib2","r")
       para=addfile(WCOSS_dir+"/gfs."+ymdm+"/"+hourm+"/gfs.t"+hourm+"z.pgrb2.0p25.f"+sprinti("%0.3i",fhours(h))+".grib2","r")
    else
       parafile ="fv3gfs."+ymdm+".t"+hourm+"z.pgrb2.0p25.f"+sprinti("%0.3i",fhours(h))+".grib2"
       if (isfilepresent(parafile)) then
          print("found FV3GFS file")
       else
          print("grabbing FV3GFS file from HPSS")
          cmd = "htar -xvf "+archive_dir+"/"+ms+"/gfsa.tar" + \
                " ./gfs."+ymdm+"/"+hourm+"/gfs.t"+hourm+"z.pgrb2.0p25.f"+sprinti("%0.3i",fhours(h))
          system(cmd)

          cmd = "mv gfs."+ymdm+"/"+hourm+"/gfs.t"+hourm+"z.pgrb2.0p25.f"+sprinti("%0.3i",fhours(h)) + \
                " ./fv3gfs."+ymdm+".t"+hourm+"z.pgrb2.0p25.f"+sprinti("%0.3i",fhours(h))+".grib2"
          system(cmd)

          cmd = "rm -fR gfs."+ymdm+"/"+hourm+"/"
          system(cmd)
       end if

       para=addfile("fv3gfs."+ymdm+".t"+hourm+"z.pgrb2.0p25.f"+sprinti("%0.3i",fhours(h))+".grib2","r")
    end if


;;;;; look for RAP analysis file on WCOSS...
;;;;; if not found, look for file in CWD.
;;;;; if not found, pull file from HPSS.

 if (CONUS_dom) then
    anlfile="/gpfs/hps/nco/ops/com/rap/prod/rap."+ymd+"/rap.t"+hour+"z.awp130pgrbf00.grib2"

    if (isfilepresent(anlfile)) then
       anl=addfile(anlfile,"r")
    else
       anlfile ="rap."+ymd+".t"+hour+"z.awp130pgrbf00.grib2"
       if (isfilepresent(anlfile)) then
          print("found RAP analysis file")
       else
          print("grabbing RAP analysis file from HPSS")
          if (toint(hour) .le. 5) then
             tar_suffix = "00-05.awp130.tar"
          else if (toint(hour) .ge. 6  .and. toint(hour) .le. 11) then
             tar_suffix = "06-11.awp130.tar"
          else if (toint(hour) .ge. 12 .and. toint(hour) .le. 17) then
             tar_suffix = "12-17.awp130.tar"
          else if (toint(hour) .ge. 18 .and. toint(hour) .le. 23) then
             tar_suffix = "18-23.awp130.tar"
          end if
          end if
          end if
          end if

          cmd = "htar -xvf /NCEPPROD/hpssprod/runhistory/rh"+year+"/"+str_get_cols(ymd,0,5)+"/"+ymd+"/com2_rap_prod_rap."+str_get_cols(modelstrings,0,7)+tar_suffix + \
                " ./rap.t"+hour+"z.awp130pgrbf00.grib2"
          system(cmd)

          cmd = "mv rap.t"+hour+"z.awp130pgrbf00.grib2" + \
                " ./rap."+ymd+".t"+hour+"z.awp130pgrbf00.grib2"
          system(cmd)
       end if

       anl=addfile("rap."+ymd+".t"+hour+"z.awp130pgrbf00.grib2","r")
    end if


 else if (NA_dom) then
    anlfile="/gpfs/hps/nco/ops/com/rap/prod/rap."+ymd+"/rap.t"+hour+"z.awip32f00.grib2"

    if (isfilepresent(anlfile)) then
       anl=addfile(anlfile,"r")
    else
       anlfile ="rap."+ymd+".t"+hour+"z.awip32f00.grib2"
       if (isfilepresent(anlfile)) then
          print("found RAP analysis file")
       else
          print("grabbing RAP analysis file from HPSS")
          if (toint(hour) .le. 5) then
             tar_suffix = "00-05.awip32.tar"
          else if (toint(hour) .ge. 6  .and. toint(hour) .le. 11) then
             tar_suffix = "06-11.awip32.tar"
          else if (toint(hour) .ge. 12 .and. toint(hour) .le. 17) then
             tar_suffix = "12-17.awip32.tar"
          else if (toint(hour) .ge. 18 .and. toint(hour) .le. 23) then
             tar_suffix = "18-23.awip32.tar"
          end if
          end if
          end if
          end if

          cmd = "htar -xvf /NCEPPROD/hpssprod/runhistory/rh"+year+"/"+str_get_cols(ymd,0,5)+"/"+ymd+"/com2_rap_prod_rap."+str_get_cols(modelstrings,0,7)+tar_suffix + \
                " ./rap.t"+hour+"z.awip32f00.grib2"
          system(cmd)

          cmd = "mv rap.t"+hour+"z.awip32f00.grib2" + \
                " ./rap."+ymd+".t"+hour+"z.awip32f00.grib2"
          system(cmd)
       end if

       anl=addfile("rap."+ymd+".t"+hour+"z.awip32f00.grib2","r")
    end if


 else

    anlfile="/gpfs/hps/nco/ops/com/gfs/prod/gfs."+ymd+"/gfs.t"+hour+"z.pgrb2.0p25.f000.grib2"

    if (isfilepresent(anlfile)) then
       anl=addfile(anlfile,"r")
    else
       anlfile ="gfs."+ymd+".t"+hour+"z.pgrb2.0p25.f000.grib2"
       if (isfilepresent(anlfile)) then
          print("found GFS analysis file")
       else
          print("grabbing GFS analysis file from HPSS")
          cmd = "htar -xvf /NCEPPROD/hpssprod/runhistory/rh"+year+"/"+str_get_cols(ymd,0,5)+"/"+ymd+"/"+gfstar+"."+modelstrings+".pgrb2_0p25.tar" + \
                " ./gfs.t"+hour+"z.pgrb2.0p25.f000"
          system(cmd)

          cmd = "mv gfs.t"+hour+"z.pgrb2.0p25.f000" + \
                " ./gfs."+ymd+".t"+hour+"z.pgrb2.0p25.f000.grib2"
          system(cmd)
       end if

       anl=addfile("gfs."+ymd+".t"+hour+"z.pgrb2.0p25.f000.grib2","r")
    end if

 end if
 end if

;;;;; look for GFS file on WCOSS...
;;;;; if not found, look for file in CWD.
;;;;; if not found, pull file from HPSS.
    prodfile="/gpfs/hps/nco/ops/com/gfs/prod/gfs."+ymdm+"/gfs.t"+hourm+"z.pgrb2.0p25.f"+sprinti("%0.3i",fhours(h))+".grib2"
    if (isfilepresent(prodfile)) then
       prod=addfile("/gpfs/hps/nco/ops/com/gfs/prod/gfs."+ymdm+"/gfs.t"+hourm+"z.pgrb2.0p25.f"+sprinti("%0.3i",fhours(h))+".grib2","r")
    else
       prodfile ="gfs."+ymdm+".t"+hourm+"z.pgrb2.0p25.f"+sprinti("%0.3i",fhours(h))+".grib2"
       if (isfilepresent(prodfile)) then
          print("found GFS file")
       else
          print("grabbing GFS file from HPSS")
          cmd = "htar -xvf /NCEPPROD/hpssprod/runhistory/rh"+yearm+"/"+str_get_cols(ymdm,0,5)+"/"+ymdm+"/"+gfstar+"."+ms+".pgrb2_0p25.tar" + \
                " ./gfs.t"+hourm+"z.pgrb2.0p25.f"+sprinti("%0.3i",fhours(h))
          system(cmd)

          cmd = "mv gfs.t"+hourm+"z.pgrb2.0p25.f"+sprinti("%0.3i",fhours(h)) + \
                " ./gfs."+ymdm+".t"+hourm+"z.pgrb2.0p25.f"+sprinti("%0.3i",fhours(h))+".grib2"
          system(cmd)
       end if

       prod=addfile("gfs."+ymdm+".t"+hourm+"z.pgrb2.0p25.f"+sprinti("%0.3i",fhours(h))+".grib2","r")
    end if


   ; print(prod)
      vnames:=getfilevarnames(prod)
    tempprod=prod->TMP_P0_L1_GLL0
    temppara=para->TMP_P0_L1_GLL0
  ; printVarSummary(tempprod)
  ; printVarSummary(temppara)


   if (CONUS_dom .or. NA_dom) then
      land_anl=anl->LAND_P0_L1_GLC0
      temp_anl=anl->TMP_P0_L1_GLC0
      lat2d := anl->gridlat_0
      lon2d := anl->gridlon_0
      temp_anl@lat2d = lat2d
      temp_anl@lon2d = lon2d
   else
      land_anl=anl->LAND_P0_L1_GLL0
      temp_anl=anl->TMP_P0_L1_GLL0
   end if

   landprod=prod->LAND_P0_L1_GLL0
   landpara=para->LAND_P0_L1_GLL0

 ; if (str_lower(skin_type) .eq. "land") then
 ;; plot in Fahrenheit
 ;    temp_anl=(temp_anl-273.15)*1.8+32.0

  ;   tempprod=mask(tempprod,landprod,1)
  ;   temppara=mask(temppara,landpara,1)
  ;   temp_anl=mask(temp_anl,land_anl,1)

 ; else if (str_lower(skin_type) .eq. "sst") then
 ;; plot in Celsius
      tempprod=tempprod-273.15
      temppara=temppara-273.15
      temp_anl=temp_anl-273.15

      tempprod=mask(tempprod,landprod,0)
      temppara=mask(temppara,landpara,0)
  ;   temp_anl=mask(temp_anl,land_anl,0)

 ; end if
 ; end if


   dif=tempprod
   dif=temppara-tempprod

   ; 3 AK 
   buoys=(/"NKTA2", "ANTA2", "46108", "DRFA2", "AUGA2"/)
   buoy_lats=(/60.75, 61.25,    59.5,     60.,    59.5/)
   buoy_lons=(/208.5,  210.,  208.25,  207.75,   206.5/)

   ; Superior
 ; buoys:=(/"45136", "45006"/)
 ; buoy_lats:=(/48.5,  47.25/)
 ; buoy_lons:=(/273., 270.25/)
   
   ; Erie
 ; buoys:=(/"45142",   "45167", "45132", "45005"/)
 ; buoy_lats:=(/42.75,   42.25,    42.5,   41.75/)
 ; buoy_lons:=(/280.75, 279.75,  278.75,   277.5/)

   ; Ontario
 ; buoys:=(/"45159", "45135", "45012"/)
 ; buoy_lats:=(/43.75, 43.75,    43.5/)
 ; buoy_lons:=(/281., 283.25,   282.5/)

   ; Woods
;  buoys:=(/"45148"/)
;  buoy_lats:=(/49.5/)
;  buoy_lons:=(/265.5/)


   print("fhr="+fhours(h))

   do i=0,dimsizes(buoys)-1
      if (landprod({buoy_lats(i)},{buoy_lons(i)}).eq.0 .and. landpara({buoy_lats(i)},{buoy_lons(i)}).eq.0) then
         print(buoys(i)+" is water point in both models")
      else if (landprod({buoy_lats(i)},{buoy_lons(i)}).eq.1 .and. landpara({buoy_lats(i)},{buoy_lons(i)}).eq.0) then
         print(buoys(i)+" is land point in GFS")
      else if (landprod({buoy_lats(i)},{buoy_lons(i)}).eq.0 .and. landpara({buoy_lats(i)},{buoy_lons(i)}).eq.1) then
         print(buoys(i)+" is land point in FV3GFS")
      else if (landprod({buoy_lats(i)},{buoy_lons(i)}).eq.1 .and. landpara({buoy_lats(i)},{buoy_lons(i)}).eq.1) then
         print(buoys(i)+" is land point in both models")
      end if
      end if
      end if
      end if
      buoy_prod=tempprod({buoy_lats(i)},{buoy_lons(i)})
      print(buoys(i)+" GFS = "+buoy_prod)
      buoy_para=temppara({buoy_lats(i)},{buoy_lons(i)})
      print(buoys(i)+" FV3GFS = "+buoy_para)
   end do 

  ;wks  = gsn_open_wks("png","fv3_2mt_"+ms+"_"+tostring(h+1))                 ; open a png file
  wks  = gsn_open_wks("png","fv3_"+scriptregion+"_land_"+ms+"_"+sprinti("%0.1i",(h)))                 ; open a png file
  ;gsn_define_colormap(wks,"BlueWhiteOrangeRed") 
  gsn_define_colormap(wks,"temp") 
  ;gsn_define_colormap(wks,"MPL_jet") 

  plot=new(3,"graphic")

  res  = True

  res@mpMinLatF                = minlat
  res@mpMaxLatF                =  maxlat
  res@mpMinLonF                = minlon
  res@mpMaxLonF                = maxlon
  ;res@mpOutlineBoundarySets="AllBoundaries"
  res@mpOutlineBoundarySets="GeophysicalAndUSStates"
  res@mpDataBaseVersion="MediumRes"
  res@gsnMaximize=True
  res@tmXBLabelFontHeightF=.008
  res@tmYLLabelFontHeightF=.008
  res@gsnAddCyclic=False
  res@gsnLeftString="GFS Fcst init "+hourm+"Z "+daym+" "+months(toint(monthm))+ " " +yearm+" valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",fhours(h))+")"
  res@mpOutlineDrawOrder="PostDraw"
  res@mpFillColor="grey75"
  res@cnInfoLabelOn=False
  res@mpFillDrawOrder="PreDraw"
  res@cnLabelMasking=True
  res@mpGeophysicalLineColor="black"
  res@mpGeophysicalLineThicknessF=2.0
  res@mpNationalLineThicknessF=2.0
  ;res@cnFillMode="RasterFill"
  ;res@cnRasterSmoothingOn=True
  res@mpUSStateLineThicknessF=1.0
  res@mpCountyLineThicknessF=.5
  ;res@mpUSStateLineThicknessF=3.0
  res@mpNationalLineColor="black"
  res@mpUSStateLineColor="black"
  res@cnLineLabelsOn=False
  res@pmLabelBarHeightF=.05
  res@lbLabelFontHeightF=.008
  res@gsnLeftStringFontHeightF=.01
  res@gsnRightStringFontHeightF=.01
  res@cnFillOn=True
  res@mpFillOn=True
  res@cnFillMode="RasterFill"
  res@cnRasterSmoothingOn=True
  res@cnLevelSelectionMode="ExplicitLevels"

  res@gsnRightString="Land/Sea"
  res@cnLevels=(/1/)
  res@cnFillColors:=(/"blue","green"/)


  res@cnLinesOn=False
  res@mpLimitMode="LatLon"
  res@gsnDraw=False
  ;res@mpProjection="Mercator"
  res@mpProjection="LambertConformal"
  if scriptregion.eq."spac" then
     res@mpLambertParallel1F = -33.0         ; two parallels
     res@mpLambertParallel2F = -45.0
  else
     res@mpLambertParallel1F = 33.0         ; two parallels
     res@mpLambertParallel2F = 45.0
  end if

  res@mpLambertMeridianF  = -95.0        ; central meridian
  if scriptregion.eq."ak" .or. scriptregion.eq."seakbays" .or. scriptregion.eq."epac" then
    res@mpLambertMeridianF  = 215.0        ; central meridian
  else if scriptregion.eq."wpac" then
    res@mpLambertMeridianF  = 145.0        ; central meridian
  else if scriptregion.eq."spac" then
    res@mpLambertMeridianF  = 160.0        ; central meridian
  else if scriptregion.eq."pr" then
    res@mpLambertMeridianF  = 294.0        ; central meridian
  end if
  end if
  end if
  end if
  ;res@lbLabelStride=1
  res@cnLinesOn=False
  res@lbLabelAutoStride=True
  res@gsnFrame=False
   res@lbLabelBarOn=True
  if scriptregion.eq."us" then
    res@mpNationalLineThicknessF=2.0
    res@mpGeophysicalLineThicknessF=2.0
  end if


  res@cnLineLabelInterval=1
  res@cnLineLabelDensityF=1.5
  ;print("plotting mix")
  plot(0) = gsn_csm_contour_map(wks,landprod,res)       ; create a default plot





  res@gsnLeftString="FV3GFS init "+hourm+"Z "+daym+" "+months(toint(monthm))+ " " +yearm+" valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",fhours(h))+")"
  plot(1) = gsn_csm_contour_map(wks,landpara,res)       ; create a default plot
  resdif=True
  resdif=res
  delete(resdif@cnFillColors)
  resdif@cnFillPalette=("BlueWhiteOrangeRed")
  
  resdif@cnLevels:=fspan(-1,1,2)

  resdif@gsnLeftString="FV3GFS minus GFS valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",fhours(h))+")"
  plot(2) = gsn_csm_contour_map(wks,dif,resdif)       ; create a default plot

  if (CONUS_dom .or. NA_dom) then
     model_string = "RAP"
  else
     model_string = "GFS"
  end if
  res@gsnLeftString=model_string+" Analysis valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",fhours(h))+")"
; plot(3) = gsn_csm_contour_map(wks,temp_anl,res)       ; create a default plot

  resP=True
  resP@gsnMaximize=True
  resP@txFontHeightF=.012
  resP@gsnPanelLabelBar=False
  ;resP@txString="initialized "+hourm+"Z "+daym+" "+months(toint(monthm))+ " " +yearm+" valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",fhours(h-1))+")"
  resP@gsnFrame=False
  gsn_panel(wks,plot,(/2,2/),resP)
 
  
print("drawing figure")
;draw(plot)
print("framing figure")
frame(wks)
print("deleting workstation")
if (CONUS_dom .or. NA_dom) then
   delete(lat2d)
   delete(lon2d)
   delete(anl)
   delete(temp_anl)
   delete(plot)
   delete(res)
   delete(resP)
   delete(hres)
   delete(resdif)
end if
delete(wks)
;print(h)
;print(max(dif))
;system("convert -trim +repage fv3_2mt_"+ms+"_"+tostring(h+1)+".png -trim +repage fv3_2mt_"+ms+"_"+sprinti("%0.2i",(h+1))+".png")                 ; open a png file
system("convert -trim +repage fv3_"+scriptregion+"_land_"+ms+"_"+sprinti("%0.1i",(h))+".png -trim +repage fv3_"+scriptregion+"_land_"+ms+"_"+sprinti("%0.1i",(h))+".png")                 ; open a png file
;system("convert -rotate 270 -density 300 -trim +repage "+ms+scriptregion+"precipgfs"+tostring(h+1)+".ps -density 300 -resize 700 -trim +repage "+ms+scriptregion+"precipgfs"+tostring(h+1)+".gif")
;system("convert -density 300 -trim +repage "+ms+scriptregion+"precipgfs"+tostring(h+1)+".ps -density 300 -resize 700 -trim +repage "+ms+scriptregion+"precipgfs"+tostring(h+1)+".gif")
end do
end



