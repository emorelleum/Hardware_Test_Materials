Program Written By: Zach Goodwyn, Jerome Mueller

This program solves a Travelling Salesman Problem of a specified size using a brute force algorithm.

To compile and run:

	Compiling this program requires you to enable openMP. Doing this differs according to the compiler you are using.

Using g++: To compile this program using g++, you must use the -fopenmp flag, as in the following example:

[user@server]$ g++ -fopenmp OpenMP_TSP.cpp

	By default, this line will still create the default ./a.out executable. You may use any other flags you wish, such as optimization flags and the -o flag.

Using Intel Compiler: 

	Before using the Intel compiler, you must specify its source. Use the command:

[user@server]$ source /opt/intel/bin/compilervars.sh intel64

	(Note: This command can also be found in the file intel_c_compiler_notes)

	To compile using intels compiler, use the -openmp flag,
as in the following:

[user@server]$ icpc -openmp OpenMP_TSP.cpp

	As a friendly reminder, recall that intel automatically uses level 2
optimizations (as opposed to g++ which will not optimize unless told). Like
g++, you may use any other relevant flags.

Using Visual Studio 2010: This program contains some Linux-specific timing
routines. You will have to remove/edit these to run this program on windows. To enable openMP in Visual Studio, go to the Project
dropdown menu, choose Properties, look at Configuration Properties, expand the
C/C++ selection (if C/C++ does not appear, make sure that you have a C or C++
file open in Visual Studio), and choose Language. On the right, your bottom option should
be OpenMP Support, click on it and choose yes.


Running: This oprogram takes four arguments
1) Number of cities
2) 0 or 1, 0 if reading the adjacency matrix (representing city costs) from a file, 1 if using a random a randomly generated adjacency matrix (will be symmetric)
3)the filename if reading data from a file, the random number generator seed if using a randomly generated set of city costs
if using a random number generator
4)The number of cores you wish to use (0 to use openMP's default value)

Whether using the g++ or intel complier, simply put the four arguments after
the executable, such as:

File example
[user@server]$ ./a.out 14 0 matrix.txt 8
OR RNG example
[user@server]$ ./a.out 14 1 5 8

In Visual Studio 2010, specify command line arguments by going to the Project
dropdown menu, choosing properties, and selecting Debugging in the Configuration
Properties. the second field should be labeled Command Arguments. Put the
arguments in that field. 

----------------------------------------------
| Command Arguments | 14 1 5 8               |
----------------------------------------------

Even though this is in the debugging section, these
arguments will be passed even during a normal execution of the program from
visual studio (i.e using ctrl+F5).
