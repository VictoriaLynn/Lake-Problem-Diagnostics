Multi-Objective Lake Problem Optimization Benchmark
==========================
Diagnostic Commands
--------------------------
Copyright (C) 2014-2015 Victoria Ward, Riddhi Singh and Pat Reed. Intended for use with [MOEAFramework](http://www.moeaframework.org) and [Borg](http://borgmoea.org). Licensed under the GNU Lesser General Public License.

This study focused on the 4 objective formulation of the classic environmental economics Lake Problem.  Simulation code is available in the main folder of this repository.  This folder provides the source code for my diagnostics and instructions to replicate my experiment.  I used version 2.1 of the MOEA Framework, which was the most current version at the time. 

Contents:
* params/: MOEA parameters to be sampled for each algorithm
* Java files: to define the Lake problem for MOEAFramework, calculate Hypervolume, and analyze attainment
* Bash scripts: to run the comparative study using the MOEAFramework, delete decision variables, fix empty sets in objective files, and analyze attainment 

To compile and run:

* Make sure you have [MOEAFramework](http://www.moeaframework.org). Download the "all-in-one executable" and put the .jar file in the main directory of this project.

*Download the source code for the MOEAFramework for compilation.

*Download the [Borg](http://borgmoea.org/) source code.  Put all Borg and Lake Source in the examples subdirectory of the MOEAFramework directory.

* Compile the Lake Problem Model: `cd MOEA\ Framework/MOEAFramework-2.1/examples && make -f MakefileLake`

* Move the Borg and Lake Problem executables into the main directory: `mv LakeProblem BorgExec ../../../`

*Also keep the Lake Problem executable in an exambles subdirectory of the main directory for the Framework optimization
	
* Compile the Java problem stub as shown below. 

	`javac -classpath MOEAFramework-<VERSION>-Executable.jar myLake4ObjStoch.java`

* Perform comparative study: Lake_Problem_Comparative_Study.sh contains all the necessary steps for the study; however, it may be necessary to 
break the file up.  My actual study had that script broken into 9 different parts.  The biggest concern is generating local reference sets.
Before doing this, one will need to delete decision variables from the set files produced by optimization 'sh delete_dec_vars.sh'.  I saved the output 
to .obj files.  Some of these had empty sets, which were not represented at all, making it necessary to use 'sh fix_empty_sets.sh' before generating 
local reference sets. 

*Once you have generated metrics for all parameterizations (both the average across all seeds and the metrics for a local reference set), you may need
to account for infinities and NaNs in the .average and .localref.metrics files.  I used `sh replace_infinities.sh` for local reference metrics
and `sh replace_NaNs.sh` for average metrics to replace infinities with very large numbers.  This was necessary for attainment calculations as the 
script for that only evaluates numbers.  A very large number was considered safe as it would still indicate the algorithm had not attained a certain level
in those instances.  NaNs and Infinities only appeared for metrics whose ideal value was 0. 

*Before evaluating attainment, you will need to calculate the hypervolume of the global reference set to normalize the hypervolume for each 
parameterization.
`javac -cp MOEAFramework-<VERSION>-Executable.jar HypervolumeEval.java` 
`java -cp MOEAFramework-<VERSION>-Executable.jar HypervolumeEval myLake4ObjStoch.reference`

*Then insert this value into Analysis_Attainment_LakeProblem.sh where appropriate, compile AWRAnalysis.java, and
run the attainment analysis.
`javac -cp MOEAFramework-<VERSION>-Executable.jar AWRAnalysis.java`
`sh Analysis_Attainment_LakeProblem.sh`

The Lake Problem Benchmark Problem is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The Lake Problem Benchmark Problem is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with the Lake Problem Benchmark Problem.  If not, see <http://www.gnu.org/licenses/>.