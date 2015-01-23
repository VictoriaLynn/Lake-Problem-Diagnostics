### Lake Problem Diagnostics (C++, Matlab, Bash)
This repository contains all of the code used for the study described in the following paper: Ward, V.L., R. Singh, P.M. Reed, and K. Keller (In Review), Confronting Tipping Points: How Well Can Multi-Objective Evolutionary Algorithms Support the Management of Environmental Thresholds?, Journal of Environmental Modelling and Software. 

Intended for use with MOEAFramework and Borg. Licensed under the GNU Lesser General Public License.

Contents: 
* `LakeProblem_4obj_1const_Control.cpp`: C++ source code for the 4 objective formulation
* `MakefileLake`: makefile that compiles the lake model, Borg and the SOWs generating code
* `Random1000SOWs.cpp`: code written by Riddhi in C++ to generate SOW files for 9 states of the world
that may be specified on line 316 of the lake model code
* `moeaframework.c` and `moeaframework.h`: provides methods included in the LakeProblem C++ code for use with the MOEAFramework. 
These are necessary to compile the code as written. 
* `reference-sets`: Folder containing the best known reference sets for optimization to each of the two distributions tested in my study.  Each result file contains the 100 decision variable values and values of the four objectives for each non-dominated solution.
* `Diagnostic-Source`: Folder containing the source code for benchmarking algorithm performance on this problem.  A walkthrough is provided at https://waterprogramming.wordpress.com/2015/01/19/algorithm-diagnostics-walkthrough-using-the-lake-problem-as-an-example-part-1-of-3-generate-pareto-approximate-fronts/.

To compile and run:


* Download the Borg source code. Put all Borg and Lake Source in the same directory.

* Type the following command `make -f MakefileLake` to compile Borg, the Lake Problem code, and the SOW generating code 

* Before you can use the lake model, you will need to generate SOW files.  This can be done simply by typing
`./Random1000SOWs.exe` and moving the desired SOW file to the directory in which you are performing the optimization.

* To optimize the lake problem with Borg use the following command

`./BorgExec.exe -v 100 -o 4 -c 1 -l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 -u 0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1 -e 0.01,0.01,0.0001,0.0001 -n 10000 -f outputfile.set -- ./LakeProblem4obj_control.exe`

Also, note if running these on thecube the executable names will not end in ".exe".  Otherwise, they will remain the same. 


Copyright (C) 2014-2015 Victoria Ward, Riddhi Singh, Pat Reed, and Klaus Keller.