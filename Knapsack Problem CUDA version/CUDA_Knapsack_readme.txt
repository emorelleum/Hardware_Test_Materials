Program adopted from a program written by Michael Crawford, written by Zach Goodwyn, Jerome Mueller

This program solves a randomly generated knapsack peroblem of a specified size.


To compile and run:

	Compiling this program requires you to use the NVidia NVCC compiler.

[user@server]$ nvcc CUDA_Knapsack.cu

	If nvcc is not included in your path (which it is not by default), you
may need to specify the full path name:

[user@server]$ usr/local/cuda/bin/nvcc CUDA_Knapsack.cu

	As usual, you can specify any other flags, such as the -o flag.

At the moment, we have no experience compiling or running CUDA programs using
Microsoft Visual Studio.

Running: This program takes four arguments
1) Number of Items
2) Seed for the random number generator
3) The number of blocks you wish to use in the program
4) The number of threads per block you wish to use in the program

Simply put the four arguments after
the executable, such as:

[user@server]$ ./a.out 14 5 8096 512

***IMPORTANT***
If the GPU you are using is also responsible for the video on your system,
your comoputer will kill your kernel function if it ties up the GPU for too
long (on our machine, a time of about 40 seconds) using what is known as a "watchdog timer". To get around this do the
following for an XWindows machine:

[user@server]$ su
enter password: ********
[root@server]# telinit 3
^^If this line does not work, hit ctrl+alt+backspace^^
Your screen should now display a bare-bones full-screen command line. Run the
program the same as above from this command prompt by navigating to the
program's directory and executing it.

A note, the program will assign a maximum weight as well as generating values and weights for each item. The formula for each value follows:

maxWeight = numItems * 10 / 2
weight for each object: random numer 0-29
value for each object: random number 0-29

To change these, you will need to edit the source code for both the main method and the kernel function.