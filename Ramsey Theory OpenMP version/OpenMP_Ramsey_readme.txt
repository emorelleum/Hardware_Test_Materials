This program solves a certain subset of the party problem R(5,5)

To compile and run:

	Compiling this program requires you to enable openMP. Doing this differs according to the compiler you are using.

Using g++: To compile this program using g++, you must use the -fopenmp flag, as in the following example:

[user@server]$ g++ -fopenmp OpenMP_Ramsey.cpp

	By default, this line will still create the default ./a.out executable. You may use any other flags you wish, such as optimization flags and the -o flag.

Using Intel Compiler:

	Before using the Intel compiler, you must specify its source. Use the command:

[user@server]$ source /opt/intel/bin/compilervars.sh intel64

	(Note: This command can also be found in the file intel_c_compiler_notes)

	To compile using intels compiler, use the -openmp flag,
as in the following:

[user@server]$ icpc -openmp OpenMP_Ramsey.cpp

	As a friendly reminder, recall that intel automatically uses level 2
optimizations (as opposed to g++ which will not optimize unless told). Like
g++, you may use any other relevant flags.

We do not have experience running this program on Visual Studio. If we did, we
imagine you would have to do the following:

Using Visual Studio 2010: To enable openMP in Visual Studio, go to the Project
dropdown menu, choose Properties, look at Configuration Properties, expand the
C/C++ selection (if C/C++ does not appear, make sure that you have a C or C++
file open in Visual Studio), and choose Language. On the right, your bottom option should
be OpenMP Support, click on it and choose yes.

Running: This oprogram takes one argument
1)The number of cores you wish to use

Whether using the g++ or intel complier, simply put the argument after
the executable, such as:

File example
[user@server]$ ./a.out 8
OR RNG example
[user@server]$ ./a.out 8

In Visual Studio 2010, specify command line arguments by going to the Project
dropdown menu, choosing properties, and selecting Debugging in the Configuration
Properties. the second field should be labeled Command Arguments. Put the
argument in that field. 

----------------------------------------------
| Command Arguments | 8                      |
----------------------------------------------

Even though this is in the debugging section, these
arguments will be passed even during a normal execution of the program from
visual studio (i.e using ctrl+F5).
