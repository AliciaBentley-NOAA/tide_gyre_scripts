#!/bin/bash

for f in ./*.png; do

   convert -trim +repage ./"$f" -trim +repage ./"$f"

done

#"convert -trim +repage fv3_"+scriptregion+"_sfcgust_"+ms+"_"+sprinti("%0.1i",(h))+".png -trim +repage fv3_"+scriptregion+"_sfcgust_"+ms+"_"+sprinti("%0.1i",(h))+".png"

exit
