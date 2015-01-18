#!/bin/bash
# Replace #\n# with #\n // Empty \n#

for f in `ls *myLake4ObjStoch_*.obj`
do
  perl -i -pe 'BEGIN{undef $/;} s/^\# Objectives = 4\n\#/\# Objectives = 4\n\/\/ Empty\n\#/mg' $f
  perl -i -pe 'BEGIN{undef $/;} s/^\#\n\#/\#\n\/\/ Empty\n\#/mg' $f
  #rm $f.bak
done
