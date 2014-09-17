Lake_Problem_Training
=====================

Copyright (C) 2014-2015 Victoria Ward, Riddhi Singh and Pat Reed. Intended for use with MOEAFramework and Borg. Licensed under the GNU Lesser General Public License.

Contents: 
*LakeProblem_4obj_1const_Control.cpp/: C++ source code for the 4 objective formulation
*MakefileLake/: makefile that compiles the lake model, Borg and the SOWs generating code
*Random1000SOWs.cpp/: code written by Riddhi in C++ to generate SOW files for 9 states of the world
that may be specified on line 316 of the lake model code

To compile and run:

*Make sure you have MOEAFramework. 

*Download the source code for the MOEAFramework for compilation

*Download the Borg source code. Put all Borg and Lake Source in the examples subdirectory of the MOEAFramework directory.

*Compile the Lake Problem Executable: cd MOEA\ Framework/MOEAFramework-2.1/examples && make -f MakefileLake

*Move the Borg and Lake Problem executables into the directory in which you want to run them.  Please note you can compile Borg 
separately from the lake model if desired, but I suggest putting it into the MOEAFramework folder so Borg, the SOW generator, and the lake model can be compiled 
simultaneously with the provided makefile.   

*Before you can use the lake model, you will need to generate SOW files.  This can be done simply by typing
./Random1000SOWs.exe and moving the desired SOW file to the directory in which you are performing the optimization.

*To optimize the lake problem with Borg use the following command
./BorgExec.exe -v 100 -o 4 -c 1 \
	-l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 \
	-u 0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1 \
	-e 0.01,0.01,0.0001,0.0001 -n 10000 -f outputfile.set -- ./LakeProblem4obj_control.exe

Also, note if running these on thecube the executable names will not end in ".exe".  Otherwise, they will remain the same. 


