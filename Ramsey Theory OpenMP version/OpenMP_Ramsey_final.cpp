#include <iostream>
#include <math.h>
#include <omp.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

using namespace std;

//constants declared
const long long NUM_GRAPHS = 335544320000LL; // A long long has a maximum value of 9223372036854775807.
const int RED = 0;
const int BLUE = 1;
const int NUM_VERTICES = 45;
const int NUM_EDGES = 990; //change to 990 for 45 vertices

//function prototypes
void generateNextGraph(int graph[]);
bool hasK5(int graph[]);

//begin main
int main(int argc, char *argv[])
{
	// Start timing how long it takes the program to check all the graphs.
	time_t start = time(NULL);//starts timer

	// Set up OpenMP code.  The number of threads will be entered on the 
	// command line.
	int numThreads; // The number of threads to use for OpenMP
	numThreads = atoi(argv[1]);
	omp_set_num_threads(numThreads);


	// Start the parallelism with OpenMP!!!
	#pragma omp parallel 
	{
		int offset[NUM_EDGES]; // Holds the binary representation of the offset.
							   // The offset is used to calculate the first graph
							   // in each set of graphs.
		int baseGraph[NUM_EDGES]; // The first graph in the set of graphs to test.
		int graph[NUM_EDGES]; // The graph in each set of graphs to test.
		long long remainder; // The offset from the base graph of the first graph in 
							 // each range.  Used to calcuate the binary value of the
							 // offset from the base graph.
		int id = omp_get_thread_num(); // The ID number of a thread for OpenMP

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
		bool result = hasK5(graph);

		long long loopIndex = 0LL;

		 // This is a for loop that tests all graphs for this core.
		for(loopIndex = 0; loopIndex < graphsPerCore; loopIndex++)
		{
			// Generate next graph.
			generateNextGraph(graph);

			// Test graph.
			result = hasK5(graph);

			// If a graph with no K5 is found, print out that graph.
			if(result == false)
			{
				for (int l = 0; l < NUM_EDGES; l++) 
				{
					cout << graph[l];
				}
				cout<<endl;
			}//end if
		}//end for loop
	}//end omp

	time_t stop = time(NULL);//ends timer
	int delta = stop - start;//calculates the difference of start and stop time
	cout << "Time taken " << delta <<" seconds " << endl;//outputs time (in seconds)

	return 0;
}//end main


/* This function tests the graph passed in to see if it contains a K5.
 * @param graph - The array holding the graph.
 * @return - Returns whether the graph contains a K5.
 */
bool hasK5(int graph[])
{
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
		return true;
	}
	else
	{
		return false;
	}
}


/* This function generates the next graph.
 * @param graph - The array holding the graph.
 */
void generateNextGraph( int graph[])
{
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
}

