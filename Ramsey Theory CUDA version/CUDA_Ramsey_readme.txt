This program solves a certain subset of the party problem R(5,5)


To compile and run:

	Compiling this program requires you to use the NVidia NVCC compiler.

[user@server]$ nvcc CUDA_Ramsey.cu

	If nvcc is not included in your path (which it is not by default), you
may need to specify the full path name:

[user@server]$ usr/local/cuda/bin/nvcc CUDA_Ramsey.cu

	As usual, you can specify any other flags, such as the -o flag.

At the moment, we have no experience compiling or running CUDA programs using
Microsoft Visual Studio.

Running: This program takes two arguments
1) The number of blocks you wish to use in the run
2) the number of threads to use per block
Simply put the two arguments after the executable: such as:

[user@server]$ ./a.out 8096 512

***IMPORTANT***
If the GPU you are using is also responsible for the video on your system,
your comoputer will kill your kernel function if it ties up the GPU for too
long (on our machine, a time of about 40 seconds) using what is known as a "watchdog timer". To get around this do the
following for a windowsX machine:

[user@server]$ su
enter password: ********
[root@server]# telinit 3
^^If this line does not work, hit ctrl+alt+backspace^^
Your screen should now display a bare-bones full-screen command line. Run the
program the same as above from this command prompt by navigating to the
program's directory and executing it.
