#!/bin/csh
#################################################################
# Csh Script to retrieve 11 online Data files of 'ds330.3',
# total 1.13M. This script uses 'wget' to download data.
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
 echo Usage: $0 YourPassword
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
  egrr/2018/20180814/z_tigge_c_egrr_20180814000000_mogreps_glob_prod_etctr_glo.xml.gz \
  egrr/2018/20180815/z_tigge_c_egrr_20180815000000_mogreps_glob_prod_etctr_glo.xml.gz \
  egrr/2018/20180816/z_tigge_c_egrr_20180816000000_mogreps_glob_prod_etctr_glo.xml.gz \
  egrr/2018/20180817/z_tigge_c_egrr_20180817000000_mogreps_glob_prod_etctr_glo.xml.gz \
  egrr/2018/20180818/z_tigge_c_egrr_20180818000000_mogreps_glob_prod_etctr_glo.xml.gz \
  egrr/2018/20180819/z_tigge_c_egrr_20180819000000_mogreps_glob_prod_etctr_glo.xml.gz \
  egrr/2018/20180820/z_tigge_c_egrr_20180820000000_mogreps_glob_prod_etctr_glo.xml.gz \
  egrr/2018/20180821/z_tigge_c_egrr_20180821000000_mogreps_glob_prod_etctr_glo.xml.gz \
  egrr/2018/20180822/z_tigge_c_egrr_20180822000000_mogreps_glob_prod_etctr_glo.xml.gz \
  egrr/2018/20180823/z_tigge_c_egrr_20180823000000_mogreps_glob_prod_etctr_glo.xml.gz \
  egrr/2018/20180824/z_tigge_c_egrr_20180824000000_mogreps_glob_prod_etctr_glo.xml.gz \
)
while($#filelist > 0)
 set syscmd = "$opt2$filelist[1]"
 echo "$syscmd ..."
 $syscmd
 shift filelist
end



