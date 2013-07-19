To compile and run openMP programs  natively on the coprocessor:

on the host machine, compile the program using Intel's compiler, except use the -mmic flag and the -vec-report3 flag:

example: 
[user@server]$ icpc -mmic -vec-report3 -openmp yourFile.cpp -o executable

Use scp to transfer the executable to the coprocessor (mic0:)

example:
[user@server]$ scp executable mic0:/tmp/executable

scp the openMP library to the coprocessor:

[user@server]$ scp /opt/intel/com[poserxe/lib/mic/libiomp5.so mic0:/tmp/libiomp5.so

(Yes, it is a long annoying command)

login to the coproccessor with ssh

[user@server]$ ssh mic0

Set the path to include the OpenMP library:

export LD_LIBRARY_PATH=/tmp

Go to the tmp directory and execute the program according to the directions given in that program's readme.


