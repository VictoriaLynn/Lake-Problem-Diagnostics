NSAMPLES=500
NSEEDS=50
METHOD=Latin
PROBLEM=myLake4ObjStoch
JAVA_ARGS="-cp MOEAFramework-2.1-Demo.jar"
set -e

# Generate the parameter samples
echo -n "Generating parameter samples..."
for ALGORITHM in ${ALGORITHMS[@]}
do
java ${JAVA_ARGS} \
    org.moeaframework.analysis.sensitivity.SampleGenerator \
    --method ${METHOD} --n ${NSAMPLES} --p ./params/${ALGORITHM}_params.txt \
    --o ${ALGORITHM}_${METHOD}
done

#Optimize the problem with Borg
ALGORITHM=Borg
SEEDS=$(seq 1 ${NSEEDS})


 for SEED in ${SEEDS}
   do
      NAME=${ALGORITHM}_${PROBLEM}_${SEED}
      PBS="\
    #PBS -N ${NAME}\n\
    #PBS -l nodes=1\n\
    #PBS -l walltime=96:00:00\n\
    #PBS -o output/${NAME}\n\
    #PBS -e error/${NAME}\n\
    cd \$PBS_O_WORKDIR\n\
	./BorgExec -v 100 -o 4 -c 1 \
	-l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 \
	-u 0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1 \
	-e 0.01,0.01,0.0001,0.0001 -p Borg_params.txt -i Borg_Latin -s ${SEED} -f ./sets/${ALGORITHM}_${PROBLEM}_${SEED}.set -- ./LakeProblem4obj_control "
    echo -e $PBS | qsub
done

#Optimize the problem with MOEAFramework algorithms that do not use epsilon dominance
ALGORITHMS=(MOEAD GDE3 NSGAII)

for ALGORITHM in ${ALGORITHMS[@]}
do
   for SEED in ${SEEDS}
   do
       NAME=${ALGORITHM}_${PROBLEM}_${SEED}
PBS="\
#PBS -N ${NAME}\n\
#PBS -l nodes=1\n\
#PBS -l walltime=96:00:00\n\
#PBS -o output/${NAME}\n\
#PBS -e error/${NAME}\n\
cd \$PBS_O_WORKDIR\n\
java ${JAVA_ARGS}
    org.moeaframework.analysis.sensitivity.Evaluator -p
    ${ALGORITHM}_params.txt -i ${ALGORITHM}_Latin -b ${PROBLEM}
    -a ${ALGORITHM} -s ${SEED} -o ./sets/${NAME}.set"
    echo -e $PBS | qsub
     done

done

#Optimize the problem with MOEAFramework algorithms that use epsilon dominance
ALGORITHMS=(eNSGAII eMOEA)

for ALGORITHM in ${ALGORITHMS[@]}
do
   for SEED in ${SEEDS}
   do
       NAME=${ALGORITHM}_${PROBLEM}_${SEED}
PBS="\
#PBS -N ${NAME}\n\
#PBS -l nodes=1\n\
#PBS -l walltime=96:00:00\n\
#PBS -o output/${NAME}\n\
#PBS -e error/${NAME}\n\
cd \$PBS_O_WORKDIR\n\
java ${JAVA_ARGS}
    org.moeaframework.analysis.sensitivity.Evaluator -p
    ${ALGORITHM}_params.txt -i ${ALGORITHM}_Latin -b ${PROBLEM}
    -a ${ALGORITHM} -e 0.01,0.01,0.0001,0.0001 -s ${SEED} -o ./sets/${NAME}.set"
    echo -e $PBS | qsub
     done

done

#Generate combined approximation set for each algorithm
ALGORITHMS=( NSGAII GDE3 eNSGAII MOEAD eMOEA Borg)
for ALGORITHM in ${ALGORITHMS[@]}
do
   echo -n "Generating combined approximation set for
      ${ALGORITHM}..."
   java ${JAVA_ARGS} \
   org.moeaframework.analysis.sensitivity.ResultFileMerger \
   -b ${PROBLEM} -e 0.01,0.01,0.0001,0.0001 -o ./SOW4/reference/${ALGORITHM}_${PROBLEM}.combined \
   ./SOW4/sets/${ALGORITHM}_${PROBLEM}_*.set
   echo "done."
done

# Generate the reference set from all combined approximation sets
echo -n "Generating reference set..."
java ${JAVA_ARGS} org.moeaframework.util.ReferenceSetMerger \
   -e 0.01,0.01,0.0001,0.0001 -o ./SOW4/reference/${PROBLEM}.reference ./SOW4/reference/*_${PROBLEM}.combined > /dev/null
echo "done."

# Generate local reference sets for each algorithm's parameterizations across all seeds
for ALGORITHM in ${ALGORITHMS[@]}
do
 java -cp MOEAFramework-2.1-Demo.jar org.moeaframework.analysis.sensitivity.ResultFileSeedMerger -d 4 -e 0.01,0.01,0.0001,0.0001 \
  --output  ./SOW4/${ALGORITHM}_${PROBLEM}.reference ./SOW4/objs/${ALGORITHM}_${PROBLEM}*.obj
done

#metrics for local reference sets
for ALGORITHM in ${ALGORITHMS[@]}
do
       NAME=${ALGORITHM}_${PROBLEM}
PBS="\
#PBS -N ${NAME}\n\
#PBS -l nodes=1\n\
#PBS -l walltime=96:00:00\n\
#PBS -o output/${NAME}\n\
#PBS -e error/${NAME}\n\
cd \$PBS_O_WORKDIR\n\
 java ${JAVA_ARGS} \
     org.moeaframework.analysis.sensitivity.ResultFileEvaluator \
     --b ${PROBLEM} --i ./SOW4/${ALGORITHM}_${PROBLEM}.reference \
     --r ./SOW4/reference/${PROBLEM}.reference --o ./SOW4/${ALGORITHM}_${PROBLEM}.localref.metrics"
    echo -e $PBS | qsub
done

#set metrics to be used for average metrics for each parameterization
for ALGORITHM in ${ALGORITHMS[@]}
do
   for SEED in ${SEEDS}
   do
       NAME=${ALGORITHM}_${PROBLEM}_${SEED}
PBS="\
#PBS -N ${NAME}\n\
#PBS -l nodes=1\n\
#PBS -l walltime=96:00:00\n\
#PBS -o output/${NAME}\n\
#PBS -e error/${NAME}\n\
cd \$PBS_O_WORKDIR\n\
 java ${JAVA_ARGS} \
     org.moeaframework.analysis.sensitivity.ResultFileEvaluator \
     --b ${PROBLEM} --i ./SOW4/sets/${ALGORITHM}_${PROBLEM}_${SEED}.set \
     --r ./SOW4/reference/${PROBLEM}.reference --o ./SOW4/metrics/${ALGORITHM}_${PROBLEM}_${SEED}.metrics"
    echo -e $PBS | qsub
     done
done

#Average the performance metrics for each parameterization across all seeds
for ALGORITHM in ${ALGORITHMS[@]}
do
   echo -n "Averaging performance metrics for ${ALGORITHM}..."
   java ${JAVA_ARGS} \
   org.moeaframework.analysis.sensitivity.SimpleStatistics \
   -m average --ignore -o ./SOW4/metrics/${ALGORITHM}_${PROBLEM}.average ./SOW4/metrics/${ALGORITHM}_${PROBLEM}_*.metrics
   echo "done."
done

# Calculate the contribution of each algorithm to the global reference set
echo ""
echo "Set contribution:"
java ${JAVA_ARGS} org.moeaframework.analysis.sensitivity.SetContribution \
   -e 0.01,0.01,0.0001,0.0001 -r ./SOW4/reference/${PROBLEM}.reference ./SOW4/reference/*_${PROBLEM}.combined
