#!/bin/bash
NSEEDS=50
ALGORITHMS=(eMOEA GDE3)
PROBLEM=myLake4ObjStoch

SEEDS=$(seq 1 ${NSEEDS})

for ALGORITHM in ${ALGORITHMS[@]}
do
 for SEED in ${SEEDS}
   do
awk 'BEGIN {FS=" "}; /^#/ {print $0}; /^[0-9]/ {printf("%s %s %s %s\n",$101,$102,$103,$104)}' ./SOW4/sets/${ALGORITHM}_${PROBLEM}_${SEED}.set \
>./SOW4/objs/${ALGORITHM}_${PROBLEM}_${SEED}.obj
done
done


