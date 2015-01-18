#!/bin/bash

NSEEDS=50
PROBLEM=myLake4ObjStoch
ALGORITHMS=(GDE3 NSGAII eNSGAII MOEAD eMOEA)

SEEDS=$(seq 1 ${NSEEDS})
JAVA_ARGS="-cp MOEAFramework-2.1-Demo.jar"
set -e

for ALGORITHM in ${ALGORITHMS[@]}
do
       NAME=${ALGORITHM}_${PROBLEM}

       sed 's/Infinity/9999.0/g' ./metrics_with_Infinities/${NAME}.localref.metrics >> ./${NAME}.localref.metrics
done


	NAME=Borg_${PROBLEM}

	sed 's/Infinity/9999.0/g' ./metrics_with_Infinities/${NAME}.localref.metrics >> ./${NAME}.localref.metrics

