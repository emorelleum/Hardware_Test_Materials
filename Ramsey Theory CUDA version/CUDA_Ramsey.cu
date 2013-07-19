#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <iostream>
#include <time.h>
#include <cuda.h>
//#include <windows.h>

using namespace std;

//#include "template_kernel.cu"
//#include <cutil_inline.h>//////////////////////  <---------------------
//#include <template_kernel.cu>

//extern "C"



////////////////////////////////////////////////////////////////////////////////////////////////////////////

//#ifndef _TOTHRAMSEYTEST_KERNEL_H_
//#define _TOTHRAMSEYTEST_KERNEL_H_

//#include <stdio.h>

//const long long MAX_NUM = 100000000;

const long long NUM_GRAPHS = 335544320000LL; // A long long has a maximum value of 9223372036854775807.
const int RED = 0;
const int BLUE = 1;
const int NUM_VERTICES = 45;
const int NUM_EDGES = 990; //change to 990 for 45 vertices


__global__ void Ramsey_Kernel( int *mySourceGraph_device, int *mySolutionGraph_device, bool *foundSolution_device, int N, int numThreads, int *answer_device) 
{
	// Calculate the base graph for this thread.

    //int numThreads; // ASSUME SET BY PARAMETER PASSED TO KERNEL
	
	int offset[NUM_EDGES]; // Holds the binary representation of the offset. The offset is used to calculate the 
                           // first graph in each set of graphs.
	int baseGraph[NUM_EDGES]; // The first graph in the set of graphs to test.
	int graph[NUM_EDGES]; // The graph in each set of graphs to test.
	long long remainder; // The offset from the base graph of the first graph in each range.  Used to calcuate 
                         //the binary value of the offset from the base graph.
	int id = blockIdx.x * blockDim.x + threadIdx.x;  // IDX FROM CUDA...

	long long graphsPerCore = NUM_GRAPHS/numThreads;

	// Calculate the first graph for each core to test.
	
	// Initializing the arrays
	for(int j=0; j < NUM_EDGES; j++)
	{
		baseGraph[j] = 0; // TODO: Make another version of baseGraph to test a different section of graphs
		offset[j] = 0;
		graph[j]=0;
	}//end for

	remainder = graphsPerCore * id;

	// Calculate first graph for each thread to test.
	
	// Translates offset into binary and stores the bits into the offset array
	for(int x = 39; x >= 0; x--)
	{
		long long powResult = pow(2.0f, x);
		if(remainder >= powResult)
		{
			offset[989-x]=1;
			remainder = remainder - powResult;
		}
		else 
		{
			offset[989-x]=0;
		}//end if else
	}//end for


	// Puts sum of offset and base graph into graph array so that
	// graph array holds the bits for the first graph to test.
	for(int m = NUM_EDGES-1; m >= 0; m--)
	{
		graph[m]= graph[m]+offset[m]+baseGraph[m];

		if(graph[m] == 2)
		{
			graph[m]=0;
			graph[m-1] = graph[m-1] +1;
		}
		else if ( graph[m]==3)
		{
			graph[m]= 1;
			graph[m-1] = graph[m-1] +1;
			
		}//end if else
	}//end for

	// Test all the graphs in the range.

	// Tests the first graph.

	//bool result = hasK5(graph);
    //////////////////////////////////////////////////////////////////////////////////////////
    // We replaced the hasK5() function call with the code.
    bool result;

    // Begin hasK5() inlining.
    bool foundK5 = false;

    // initialize counters
    int vertex1 = 0;
    int vertex2 = 1;
    int vertex3 = 2;
    int vertex4 = 3;
    int vertex5 = 4;

    /* These five nested while loops select the 5 vertices that 
       we will test to see if they form a K5. The outermost while loop
       selects the smallest numbered vertex.The next while loop selets the second smallest
       numbered vertex and so on... The set of while loops test every possible
       set of five vertices that could form a K5 until it finds one or has tested every possible
       set.
    */

    while (!foundK5 && vertex1 < NUM_VERTICES - 4)
    {
        while (!foundK5 && vertex2 < NUM_VERTICES - 3)
        {
	        while (!foundK5 && vertex3 < NUM_VERTICES - 2)
	        {
		        while (!foundK5 && vertex4 < NUM_VERTICES - 1)
		        {
			        while (!foundK5 && vertex5 < NUM_VERTICES)
			        {
				        if (graph[((NUM_VERTICES * vertex1) + vertex2 - (((vertex1 + 1)*(vertex1 + 2))/ 2))] == RED &&
					        graph[((NUM_VERTICES * vertex1) + vertex3 - (((vertex1 + 1)*(vertex1 + 2))/ 2))] == RED &&
					        graph[((NUM_VERTICES * vertex1) + vertex4 - (((vertex1 + 1)*(vertex1 + 2))/ 2))] == RED &&
					        graph[((NUM_VERTICES * vertex1) + vertex5 - (((vertex1 + 1)*(vertex1 + 2))/ 2))] == RED &&							
					        graph[((NUM_VERTICES * vertex2) + vertex3 - (((vertex2 + 1)*(vertex2 + 2))/ 2))] == RED &&							
					        graph[((NUM_VERTICES * vertex2) + vertex4 - (((vertex2 + 1)*(vertex2 + 2))/ 2))] == RED &&							
					        graph[((NUM_VERTICES * vertex2) + vertex5 - (((vertex2 + 1)*(vertex2 + 2))/ 2))] == RED &&							
					        graph[((NUM_VERTICES * vertex3) + vertex4 - (((vertex3 + 1)*(vertex3 + 2))/ 2))] == RED &&							
					        graph[((NUM_VERTICES * vertex3) + vertex5 - (((vertex3 + 1)*(vertex3 + 2))/ 2))] == RED &&
					        graph[((NUM_VERTICES * vertex4) + vertex5 - (((vertex4 + 1)*(vertex4 + 2))/ 2))] == RED)
				        {
					        foundK5 = true;
				        }
				        else if (graph[((NUM_VERTICES * vertex1) + vertex2 - (((vertex1 + 1)*(vertex1 + 2))/ 2))] == BLUE&&
					        graph[((NUM_VERTICES * vertex1) + vertex3 - (((vertex1 + 1)*(vertex1 + 2))/ 2))] == BLUE &&
					        graph[((NUM_VERTICES * vertex1) + vertex4 - (((vertex1 + 1)*(vertex1 + 2))/ 2))] == BLUE &&
					        graph[((NUM_VERTICES * vertex1) + vertex5 - (((vertex1 + 1)*(vertex1 + 2))/ 2))] == BLUE &&
					        graph[((NUM_VERTICES * vertex2) + vertex3 - (((vertex2 + 1)*(vertex2 + 2))/ 2))] == BLUE &&
					        graph[((NUM_VERTICES * vertex2) + vertex4 - (((vertex2 + 1)*(vertex2 + 2))/ 2))] == BLUE &&
					        graph[((NUM_VERTICES * vertex2) + vertex5 - (((vertex2 + 1)*(vertex2 + 2))/ 2))] == BLUE &&
					        graph[((NUM_VERTICES * vertex3) + vertex4 - (((vertex3 + 1)*(vertex3 + 2))/ 2))] == BLUE &&
					        graph[((NUM_VERTICES * vertex3) + vertex5 - (((vertex3 + 1)*(vertex3 + 2))/ 2))] == BLUE &&
					        graph[((NUM_VERTICES * vertex4) + vertex5 - (((vertex4 + 1)*(vertex4 + 2))/ 2))] == BLUE)
				        {
					        foundK5 = true;
				        }
				        vertex5++;
			        }
			        vertex4++;
			        vertex5 = vertex4 + 1;
		        }
		        vertex3++;
		        vertex4 = vertex3 + 1;
		        vertex5 = vertex4 + 1;
	        }
	        vertex2++;
	        vertex3 = vertex2 + 1;
	        vertex4 = vertex3 + 1;
	        vertex5 = vertex4 + 1;
        }
        vertex1++;
        vertex2 = vertex1 + 1;
        vertex3 = vertex2 + 1;
        vertex4 = vertex3 + 1;
        vertex5 = vertex4 + 1;
    }

    if (foundK5 == true)
    {
        result = true;
    }
    else
    {
        result = false;
    }
    // End hasK5() inlining.
    //////////////////////////////////////////////////////////////////////////////////////////

	// If a graph with no K5 is found, print out that graph.
	if(result == false)
	{
        *foundSolution_device = true;
        answer_device[id] = 1;
	}//end if

	long long loopIndex = 0LL;

	 // This is a for loop that tests all graphs for this core.
	for(loopIndex = 0; loopIndex < graphsPerCore; loopIndex++)
	{
		// Generate next graph.

        // We have replaced the function call for generateNextGraph() with the code.
		//generateNextGraph(graph);
        //////////////////

        bool carry = false;
        int index = NUM_EDGES -1;	

        do 
        {
            //add 1 and check for carry 
            if ( graph[index] == 0)
            {
	            carry = false;
	            graph[index] = 1; //set to 1
            }
            else
            {
	            carry = true;
	            graph[index] = 0; //set to 0
            }//end if/else

            index = index - 1;
        }
        while((carry == true) && (index >= 0));

        index = NUM_EDGES - 1;
        //////////////////


		// Test graph.
        //result = hasK5(graph);

        //////////////////////////////////////////////////////////////////////////////////////////
        // We replaced the hasK5() function call with the code.

        // Begin hasK5() inlining.
        bool foundK5 = false;

        // initialize counters
        int vertex1 = 0;
        int vertex2 = 1;
        int vertex3 = 2;
        int vertex4 = 3;
        int vertex5 = 4;

        /* These five nested while loops select the 5 vertices that 
           we will test to see if they form a K5. The outermost while loop
           selects the smallest numbered vertex.The next while loop selets the second smallest
           numbered vertex and so on... The set of while loops test every possible
           set of five vertices that could form a K5 until it finds one or has tested every possible
           set.
        */

        while (!foundK5 && vertex1 < NUM_VERTICES - 4)
        {
	        while (!foundK5 && vertex2 < NUM_VERTICES - 3)
	        {
		        while (!foundK5 && vertex3 < NUM_VERTICES - 2)
		        {
			        while (!foundK5 && vertex4 < NUM_VERTICES - 1)
			        {
				        while (!foundK5 && vertex5 < NUM_VERTICES)
				        {
					        if (graph[((NUM_VERTICES * vertex1) + vertex2 - (((vertex1 + 1)*(vertex1 + 2))/ 2))] == RED &&
						        graph[((NUM_VERTICES * vertex1) + vertex3 - (((vertex1 + 1)*(vertex1 + 2))/ 2))] == RED &&
						        graph[((NUM_VERTICES * vertex1) + vertex4 - (((vertex1 + 1)*(vertex1 + 2))/ 2))] == RED &&
						        graph[((NUM_VERTICES * vertex1) + vertex5 - (((vertex1 + 1)*(vertex1 + 2))/ 2))] == RED &&							
						        graph[((NUM_VERTICES * vertex2) + vertex3 - (((vertex2 + 1)*(vertex2 + 2))/ 2))] == RED &&							
						        graph[((NUM_VERTICES * vertex2) + vertex4 - (((vertex2 + 1)*(vertex2 + 2))/ 2))] == RED &&							
						        graph[((NUM_VERTICES * vertex2) + vertex5 - (((vertex2 + 1)*(vertex2 + 2))/ 2))] == RED &&							
						        graph[((NUM_VERTICES * vertex3) + vertex4 - (((vertex3 + 1)*(vertex3 + 2))/ 2))] == RED &&							
						        graph[((NUM_VERTICES * vertex3) + vertex5 - (((vertex3 + 1)*(vertex3 + 2))/ 2))] == RED &&
						        graph[((NUM_VERTICES * vertex4) + vertex5 - (((vertex4 + 1)*(vertex4 + 2))/ 2))] == RED)
					        {
						        foundK5 = true;
					        }
					        else if (graph[((NUM_VERTICES * vertex1) + vertex2 - (((vertex1 + 1)*(vertex1 + 2))/ 2))] == BLUE&&
						        graph[((NUM_VERTICES * vertex1) + vertex3 - (((vertex1 + 1)*(vertex1 + 2))/ 2))] == BLUE &&
						        graph[((NUM_VERTICES * vertex1) + vertex4 - (((vertex1 + 1)*(vertex1 + 2))/ 2))] == BLUE &&
						        graph[((NUM_VERTICES * vertex1) + vertex5 - (((vertex1 + 1)*(vertex1 + 2))/ 2))] == BLUE &&
						        graph[((NUM_VERTICES * vertex2) + vertex3 - (((vertex2 + 1)*(vertex2 + 2))/ 2))] == BLUE &&
						        graph[((NUM_VERTICES * vertex2) + vertex4 - (((vertex2 + 1)*(vertex2 + 2))/ 2))] == BLUE &&
						        graph[((NUM_VERTICES * vertex2) + vertex5 - (((vertex2 + 1)*(vertex2 + 2))/ 2))] == BLUE &&
						        graph[((NUM_VERTICES * vertex3) + vertex4 - (((vertex3 + 1)*(vertex3 + 2))/ 2))] == BLUE &&
						        graph[((NUM_VERTICES * vertex3) + vertex5 - (((vertex3 + 1)*(vertex3 + 2))/ 2))] == BLUE &&
						        graph[((NUM_VERTICES * vertex4) + vertex5 - (((vertex4 + 1)*(vertex4 + 2))/ 2))] == BLUE)
					        {
						        foundK5 = true;
					        }
					        vertex5++;
				        }
				        vertex4++;
				        vertex5 = vertex4 + 1;
			        }
			        vertex3++;
			        vertex4 = vertex3 + 1;
			        vertex5 = vertex4 + 1;
		        }
		        vertex2++;
		        vertex3 = vertex2 + 1;
		        vertex4 = vertex3 + 1;
		        vertex5 = vertex4 + 1;
	        }
	        vertex1++;
	        vertex2 = vertex1 + 1;
	        vertex3 = vertex2 + 1;
	        vertex4 = vertex3 + 1;
	        vertex5 = vertex4 + 1;
        }

        if (foundK5 == true)
        {
	        result = true;
        }
        else
        {
	        result = false;
        }
        // End hasK5() inlining.
        //////////////////////////////////////////////////////////////////////////////////////////

		// If a graph with no K5 is found, print out that graph.
		if(result == false)
		{
            *foundSolution_device = true;
            answer_device[id] = loopIndex+1;
		}//end if
	}//end for loop

}

//#endif


///////////////////////////////////////////////////////////////////////////////////////////////////////////









int cToI(char* c)//used to implement arguments
{
	int length = strlen(c);\
	int ret = 0;
	for(int x = 0; x < length; x++)
	{
		ret *= 10;
		if(c[x] >= '1' && c[x] <= '9')
		{
			ret += c[x] - '1' + 1;
		}
	}
	return ret;
}









int main(int argc, char **argv)
{

	if(argc != 3)
	{
		cout << "Need blocks and Blocks-Per-Thread as arguments" << endl;
	}

	// ********START TIMING********
	time_t start = time(NULL);//starts timer

	int N = 990;
	
	size_t size = N * sizeof(int);

	//*************ALLOCATE MEMORY FOR HOST**********

    // starting graph for GPU to use
	int* mySourceGraph_host = (int*) malloc(size); 

    // place for solution if we find it on host
    int* mySolutionGraph_host = (int*) malloc(size); 

    // flag to tell us if we find a graph
    bool foundSolution_host;

    // This array holds 0 in each slot when initialized.  It will hold the number+1 of
    // the graph that contains no red or blue K5 (if found) after the GPU executes the
    // kernel and the array is copied from the GPU.  In other words, if a slot in the 
    // array holds the value x which is greater than 0, then subtract 1 from x to get
    // the graph (aka 0 to 19,999 or 0 to 9,999) number.  Add that to the (array index *
    // 10,000 or 20,000 depending on how many graphs each thread tests).  Then convert that
    // to binary and voila! you have the graph that shows R(5,5) >= 46.
    int* answer_host = (int*) malloc(16777216 * sizeof(int));

    // Fill the array with zeros.  This function prevents an optimizing compiler from
    // optimizing out this step which can occur with ZeroMemory().
    //SecureZeroMemory(answer_host, sizeof(answer_host));
	for(long long inc = 0; inc < 16777216; inc++)
	{
		answer_host[inc] = 0;
	}

    //***********************************************
	
	cout << "memory allocated on host" << endl <<endl;

    //initialize the memory allocated on host


    for(int i=0; i < N; i++)
    {
        mySourceGraph_host[i] = 0;
        mySolutionGraph_host[i] = -999;
    }
    foundSolution_host = false;

	
	//************ALLOCATE MEMORY ON CUDA CARD********
	int* mySourceGraph_device; 
	cudaMalloc(&mySourceGraph_device,size); 

	int* mySolutionGraph_device; 
	cudaMalloc(&mySolutionGraph_device,size);

	bool* foundSolution_device; 
	cudaMalloc(&foundSolution_device,sizeof(bool));

    int* answer_device;
   // cudaMalloc(&answer_device, (16777216 * sizeof(int)));
cudaError_t error_id5 = cudaMalloc(&answer_device, (16777216 * sizeof(int)));
	if (error_id5 != cudaSuccess) {cout << "OMFG!!!!!!!!!!!" << endl;}
    cudaMemset(answer_device, 0, sizeof(*answer_device));
	//************************************************
	
	cout<< "memory allocated on device " <<endl << endl;

 
	//*************TRANSFER FROM HOST TO DEVICE********
	cudaMemcpy(mySourceGraph_device, mySourceGraph_host, size, cudaMemcpyHostToDevice);

	cudaMemcpy(mySolutionGraph_device, mySolutionGraph_host, size, cudaMemcpyHostToDevice);

    cudaMemcpy(foundSolution_device, &foundSolution_host, sizeof(bool), cudaMemcpyHostToDevice);
	//**************************************************

	cout << " transfered memory from host to device " << endl << endl;


    //Determine if this is a CUDA 1.x or 2.x Compute Capability card

    //***********MAJOR.MINOR VERSION NUMBER ***************
	int /*dev,*/ deviceCount = 0;
    int majorNum;
	cudaError_t error_id = cudaGetDeviceCount(&deviceCount);
	if (error_id != cudaSuccess) 
	{
		printf( "cudaGetDeviceCount returned %d\n-> %s\n", (int)error_id, cudaGetErrorString(error_id) );
	} 

		cudaSetDevice(0);
		cudaDeviceProp deviceProp;
		cudaGetDeviceProperties(&deviceProp, 0);
		cout<<endl;
		printf("  CUDA Capability Major/Minor version number:   %d.%d\n", deviceProp.major, deviceProp.minor);
		majorNum = deviceProp.major;


/*
	for (dev = 0; dev < deviceCount; ++dev) 
	{
		cudaDeviceProp deviceProp;
		cudaGetDeviceProperties(&deviceProp, dev);
		cout<<endl;
		printf("  CUDA Capability Major/Minor version number:   %d.%d\n", deviceProp.major, deviceProp.minor);
		majorNum = deviceProp.major;
	}//end for loop*/

cout << "The major num is... " << majorNum << endl;
	//*****************************************************

    //*******KERNEL SET-UP***********************
    int numThreads = 0; // The number of threads being used by the GPU.
    //sets the grid,block,thread values depeding on the major and minor numbers
    dim3 grid, block; 
    if (majorNum == 3)//if card is 3.x compute capability, use these parameters for kernel TODO: OMFG UPDATE THIS FOR A REAL SET OF 3.X VALUES!!!
    {
        grid.x = 32768;
	    grid.y = 1;
	    block.x = 1024;
	    block.y = 1;
        numThreads = 33554432;
    }
    else if (majorNum == 2)//if card is 2.x compute capability, use these parameters for kernel
    {
        grid.x = 32768;
	    grid.y = 1;
	    block.x = 1024;
	    block.y = 1;
        numThreads = 33554432;
    }
    else //otherwise if card is 1.x compute capability, use these parameters
    {
        grid.x = 32768;
	    grid.y = 1;
	    block.x = 512;
	    block.y = 1;
        numThreads = 16777216;
    }
	//***********************************************

	//*******KERNEL CALL ****************************
/*    Ramsey_Kernel<<<grid, block>>>(mySourceGraph_device, mySolutionGraph_device, foundSolution_device, N, numThreads, answer_device);
	cout<< " kernel called here " << endl << endl;
*/	//***********************************************
int blocks = cToI(argv[1]);
int threadsPB = cToI(argv[2]);
numThreads = blocks * threadsPB;
//modified Kernel call////////////////////////////
Ramsey_Kernel<<<blocks, threadsPB>>>(mySourceGraph_device, mySolutionGraph_device, foundSolution_device, N, numThreads, answer_device);
	cout<< " kernel called here " << endl << endl;
	
 	
	//*******TRANSFER DATA BACK TO HOST*************
	if (cudaMemcpy(&foundSolution_host, foundSolution_device, sizeof(bool)/*size*/, cudaMemcpyDeviceToHost) != cudaSuccess)
{cout << "FAILLLLLL on copy mem dev-> host" << endl;
	cudaError_t error_id2 = cudaGetLastError();
cout << "ERROR!!! " << cudaGetErrorString(error_id2) << endl;
}
	//cudaMemcpy(&foundSolution_host, foundSolution_device, size, cudaMemcpyDeviceToHost);
	//**********************************************
	
	// Check if a graph with no monochromatic K5 was found and if so
	// print it out.
    if (foundSolution_host == true) 
    {
        cout << "Graph found! " << endl;
        cout << " The graph we found is : " << mySolutionGraph_host << endl;
        // Copy the (64 MB - gack!!!) array holding solution from the GPU to the Host
        // This is only ever done if we actually find the graph that proves R(5,5) >= 46
        // so we never expect it to run and therefore won't get a performance hit...
	    cudaMemcpy(answer_host, answer_device, (16777216 * sizeof(int)), cudaMemcpyDeviceToHost);
        
        bool foundAnswerInArray = false;
        int counter = 0;
        while ((foundAnswerInArray == false) && (counter < 16777216))
        {
            if (answer_host[counter] > 0) // We found our answer (aka counter-example showing R(5,5) >= 46
            {
                foundAnswerInArray = true;

		        // Calculate the base graph for this thread.

		        int offset[NUM_EDGES]; // Holds the binary representation of the offset. The offset is used to calculate the 
							           // first graph in each set of graphs.
		        int baseGraph[NUM_EDGES]; // The first graph in the set of graphs to test.
		        int graph[NUM_EDGES]; // The graph in each set of graphs to test.
		        long long remainder; // The offset from the base graph of the first graph in each range.  Used to calcuate 
							         //the binary value of the offset from the base graph.

		        int id = counter; // Set id to the first index of the array that holds an answer.
		        int whichGraph = answer_host[counter] - 1; // which graph was it in the thread that found our graph with no K5.

		        long long graphsPerCore = NUM_GRAPHS/numThreads;

		        // Calculate the first graph for each core to test.

		        // Initializing the arrays
		        for(int j=0; j < NUM_EDGES; j++)
		        {
			        baseGraph[j] = 0; // TODO: Make another version of baseGraph to test a different section of graphs
			        offset[j] = 0;
			        graph[j]=0;
		        }//end for

		        remainder = graphsPerCore * id;

		        // Calculate first graph for each thread to test.

		        // Translates offset into binary and stores the bits into the offset array
		        for(int x = 39; x >= 0; x--)
		        {
			        long long powResult = pow(2.0f, x);
			        if(remainder >= powResult)
			        {
				        offset[989-x]=1;
				        remainder = remainder - powResult;
			        }
			        else 
			        {
				        offset[989-x]=0;
			        }//end if else
		        }//end for

		        // Puts sum of offset and base graph into graph array so that
		        // graph array holds the bits for the first graph to test.
		        for(int m = NUM_EDGES-1; m >= 0; m--)
		        {
			        graph[m]= graph[m]+offset[m]+baseGraph[m];

			        if(graph[m] == 2)
			        {
				        graph[m]=0;
				        graph[m-1] = graph[m-1] +1;
			        }
			        else if ( graph[m]==3)
			        {
				        graph[m]= 1;
				        graph[m-1] = graph[m-1] +1;
        				
			        }//end if else
		        }//end for


		        // reinitialize offset array
		        for(int j=0; j < NUM_EDGES; j++)
		        {
			        offset[j] = 0;

		        }//end for


		        // convert whichGraph to binary and shove it in offset[] array
		        // Translates offset into binary and stores the bits into the offset array
		        remainder = whichGraph;
		        for(int x = 39; x >= 0; x--)
		        {
			        long long powResult = pow(2.0f, x);
			        if(remainder >= powResult)
			        {
				        offset[989-x]=1;
				        remainder = remainder - powResult;
			        }
			        else 
			        {
				        offset[989-x]=0;
			        }//end if else
		        }//end for



		        // Puts sum of offset and base graph into graph array so that
		        // graph array holds the bits for the first graph to test.
		        for(int m = NUM_EDGES-1; m >= 0; m--)
		        {
			        graph[m]= graph[m]+offset[m];

			        if(graph[m] == 2)
			        {
				        graph[m]=0;
				        graph[m-1] = graph[m-1] +1;
			        }
			        else if ( graph[m]==3)
			        {
				        graph[m]= 1;
				        graph[m-1] = graph[m-1] +1;
        				
			        }//end if else
		        }//end for

	            //prints out binary graph
	            for(int i = 0; i < NUM_EDGES; i++)
	            {
		            cout << graph[i];

	            }//end for            
            }
            else
            {
                counter ++;
            }
        }
        
    }
    else
    {
        cout << " No Graph was found. " << endl;

    }//end if else


	//******FREE MEMORY ON HOST**********
	//free(mySourceGraph_host);
	//free(mySolutionGraph_host);
	//free(&foundSolution_host);
    //free(answer_host);
	//***********************************

    //******FREE MEMORY ON DEVICE********
	cudaFree(mySourceGraph_device);
	cudaFree(mySolutionGraph_device);
	cudaFree(foundSolution_device);
	cudaFree(answer_device);
	//***********************************


	cout << " memory from host and device freed " << endl << endl;

	//*********END TIMING IN SECONDS***************************
	time_t stop = time(NULL);
	int delta = stop - start;
	cout << "Time taken " << delta <<" seconds " << endl;
	//**********************************************
		
}
//end main




