# Script to retrieve 13 online Data files of 'ds330.3',
# # total 233.93M. This script uses 'wget' to download data.
# #
# # Highlight this script by Select All, Copy and Paste it into a file;
# # make the file executable and run it on command line.
# #
# # You need pass in your password as a parameter to execute
# # this script; or you can set an environment variable RDAPSWD
# # if your Operating System supports it.
# #
# # Contact schuster@ucar.edu (Doug Schuster) for further assistance.
# #################################################################

set pswd = $1
if(x$pswd == x && `env | grep RDAPSWD` != '') then
 set pswd = $RDAPSWD
 endif
 if(x$pswd == x) then
  echo
   echo Usage: $0 fyS9qAjD
    echo
     exit 1
     endif
     set v = `wget -V |grep 'GNU Wget ' | cut -d ' ' -f 3`
     set a = `echo $v | cut -d '.' -f 1`
     set b = `echo $v | cut -d '.' -f 2`
     if(100 * $a + $b > 109) then
      set opt = 'wget --no-check-certificate'
      else
       set opt = 'wget'
       endif
       set opt1 = '-O Authentication.log --save-cookies auth.rda_ucar_edu --post-data'
       set opt2 = "email=ambentley@albany.edu&passwd=$pswd&action=login"
       $opt $opt1="$opt2" https://rda.ucar.edu/cgi-bin/login
       set opt1 = "-N --load-cookies auth.rda_ucar_edu"
       set opt2 = "$opt $opt1 http://rda.ucar.edu/data/ds330.3/"
       set filelist = ( \
  kwbc/2018/20180912/z_tigge_c_kwbc_20180912120000_CENS_glob_prod_esttr_glo.xml \
  kwbc/2018/20180912/z_tigge_c_kwbc_20180912120000_CMC_glob_prod_sttr_glo.xml \
  kwbc/2018/20180912/z_tigge_c_kwbc_20180912120000_GEFS_glob_prod_esttr_glo.xml \
  kwbc/2018/20180912/z_tigge_c_kwbc_20180912120000_GFS_glob_prod_sttr_glo.xml \
  kwbc/2018/20180913/z_tigge_c_kwbc_20180913120000_CENS_glob_prod_esttr_glo.xml \
  kwbc/2018/20180913/z_tigge_c_kwbc_20180913120000_CMC_glob_prod_sttr_glo.xml \
  kwbc/2018/20180913/z_tigge_c_kwbc_20180913120000_GEFS_glob_prod_esttr_glo.xml \
  kwbc/2018/20180913/z_tigge_c_kwbc_20180913120000_GFS_glob_prod_sttr_glo.xml \
				 )
				 while($#filelist > 0)
				  set syscmd = "$opt2$filelist[1]"
				   echo "$syscmd ..."
				    $syscmd
				     shift filelist
				     end

				     rm -f auth.rda_ucar_edu Authentication.log
				     exit 0

