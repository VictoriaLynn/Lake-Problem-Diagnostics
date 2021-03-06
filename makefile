# This make file compiles the C/C++ executables used by examples/Example5.java
# and examples/Example6.java.
#
# This make file assumes it is being run on a Unix-like environment with GCC
# and Make installed.  Windows users can install MinGW/MSYS or Cygwin.
#
# Run 'make' to build all files

CC = gcc
CC2    = g++
FLAGS = -Wall -O3
LIBS   = -lm

main: LakeProblem4obj_control Random1000SOWs BorgExec

clean:
	rm -f moeaframework.o libmoea.a BorgExec LakeProblem4obj_control Random1000SOWs

libmoea.a: moeaframework.c moeaframework.h
	$(CC) $(FLAGS) -o moeaframework.o -c moeaframework.c
	ar rcs libmoea.a moeaframework.o
	rm -f moeaframework.o

LakeProblem4obj_control: libmoea.a LakeProblem_4obj_1const_Control.cpp
	$(CC2) $(FLAGS) -o LakeProblem4obj_control LakeProblem_4obj_1const_Control.cpp -L. -lmoea $(LIBS)

Random1000SOWs: Random1000SOWs.cpp
	$(CC2) $(FLAGS) -I ../../../boost_1_56_0 -o Random1000SOWs Random1000SOWs.cpp -L. $(LIBS)

BorgExec: borg.c borg.h
	${CC} ${FLAGS} -o BorgExec frontend.c borg.c mt19937ar.c -L. $(LIBS)
