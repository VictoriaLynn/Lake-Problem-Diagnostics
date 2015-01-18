#!/bin/bash
#source setup_LTM.sh

dim=4
problem=myLake4ObjStoch
epsilon="0.01,0.01,0.0001,0.0001"

algorithms="Borg eMOEA eNSGAII GDE3 MOEAD NSGAII"
seeds="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50"
percentiles="`seq 1 1 100`"
thresholds=(`seq 0.01 0.01 1.0`)

#compute averages across metrics
#echo "Computing averages across metrics..."
#for algorithm in ${algorithms}
#do
#  echo "Working on: " ${algorithm}
#  java -classpath `cygpath -wp $CLASSPATH` org.moeaframework.analysis.sensitivity.MetricFileStatistics --mode average --output $WORK/metrics/${algorithm}_${problem}.average $WORK/metrics/${algorithm}_${problem}_*.metrics
#done
#echo "Done!"

#compute search control metrics (for best and attainment)
echo "Computing hypervolume search control metrics..."
for algorithm in ${algorithms}
do
  echo "Working on: " ${algorithm}
  counter=$1
  for percentile in ${percentiles}
  do
    java -classpath MOEAFramework-2.1-Demo.jar AWRAnalysis --parameterFile ./${algorithm}_params.txt --parameters ./${algorithm}_Latin --metric 0 --threshold ${thresholds[$counter]} --hypervolume 0.8635 ./SOW4/local_reference/${algorithm}_${problem}.localref.metrics > ./SOW4/attainment/Hypervolume_${percentile}_${algorithm}.txt
    counter=$((counter+1))
  done
  done
echo "Done!"

echo "Computing generational distance search control metrics..."
for algorithm in ${algorithms}
do
  echo "Working on: " ${algorithm}
  counter=$1
  for percentile in ${percentiles}
  do
    java -classpath MOEAFramework-2.1-Demo.jar AWRAnalysis --parameterFile ./${algorithm}_params.txt --parameters ./${algorithm}_Latin --metric 1 --threshold ${thresholds[$counter]} ./SOW4/local_reference/${algorithm}_${problem}.localref.metrics > ./SOW4/attainment/GenDist_${percentile}_${algorithm}.txt
    counter=$((counter+1))
  done
done
echo "Done!"

#echo "Computing inverse generational distance search control metrics..."
#for algorithm in ${algorithms}
#do
#  echo "Working on: " ${algorithm}
#  counter=$1
#  for percentile in ${percentiles}
#  do
#    java -classpath `cygpath -wp $CLASSPATH` AWRAnalysis --parameterFile $WORK/params/${algorithm}_Params --parameters $WORK/params/${algorithm}_LHS --metric 2 --threshold ${thresholds[$counter]} $WORK/metrics/${algorithm}_${problem}.average > $WORK/attainment/InvGenDist_${percentile}_${algorithm}.txt
#    counter=$((counter+1))
#  done
#done
#echo "Done!"

#echo "Computing spacing control metrics..."
#for algorithm in ${algorithms}
#do
#  echo "Working on: " ${algorithm}
#  counter=$1
#  for percentile in ${percentiles}
#  do
#    java -classpath `cygpath -wp $CLASSPATH` AWRAnalysis --parameterFile $WORK/params/${algorithm}_Params --parameters $WORK/params/${algorithm}_LHS --metric 3 --threshold ${thresholds[$counter]} $WORK/metrics/${algorithm}_${problem}.average > $WORK/attainment/Spacing_${percentile}_${algorithm}.txt
#    counter=$((counter+1))
#  done
#done
#echo "Done!"

#echo "Computing additive epsilon indicator search control metrics..."
#for algorithm in ${algorithms}
#do
#  echo "Working on: " ${algorithm}
#  counter=$1
#  for percentile in ${percentiles}
#  do
#    java -classpath `cygpath -wp $CLASSPATH` AWRAnalysis --parameterFile $WORK/params/${algorithm}_Params --parameters $WORK/params/${algorithm}_LHS --metric 4 --threshold ${thresholds[$counter]} $WORK/metrics/${algorithm}_${problem}.average > $WORK/attainment/EpsInd_${percentile}_${algorithm}.txt
#    counter=$((counter+1))
#  done
#done
#echo "Done!"

#echo "Computing maximum Pareto front error search control metrics..."
#for algorithm in ${algorithms}
#do
#  echo "Working on: " ${algorithm}
#  counter=$1
#  for percentile in ${percentiles}
#  do
#    java -classpath `cygpath -wp $CLASSPATH` AWRAnalysis --parameterFile $WORK/params/${algorithm}_Params --parameters $WORK/params/${algorithm}_LHS --metric 5 --threshold ${thresholds[$counter]} $WORK/metrics/${algorithm}_${problem}.average > $WORK/attainment/MaxPFE_${percentile}_${algorithm}.txt
#    counter=$((counter+1))
#  done
#done
#echo "Done!"

echo "Computing additive epsilon indicator search control metrics..."
for algorithm in ${algorithms}
do
  echo "Working on: " ${algorithm}
  counter=$1
  for percentile in ${percentiles}
  do
    java -classpath MOEAFramework-2.1-Demo.jar AWRAnalysis --parameterFile ./${algorithm}_params.txt --parameters ./${algorithm}_Latin --metric 4 --threshold ${thresholds[$counter]} ./SOW4/local_reference/${algorithm}_${problem}.localref.metrics > ./SOW4/attainment/EpsInd_${percentile}_${algorithm}.txt
    counter=$((counter+1))
  done
done
echo "Done!"
