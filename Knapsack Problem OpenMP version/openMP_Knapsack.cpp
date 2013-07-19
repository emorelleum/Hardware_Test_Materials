/*
 * Michael Crawford
 * David Toth, Ph.D.
 * CPSC 370W
 * The Knapsack Problem, openMP version
 *
 * Command line arguments:
 * argv[1] = test file name 
 */

#include <iostream>
#include <time.h> 
#include <fstream>
#include <algorithm>
#include <omp.h>

using namespace std;

/* A simple factorial function
 */
long fact(int i) 
{
	return i == 0 ? 1 : i*fact(i-1); 
}

/* Determines the factoratic at an array location given a permutation number
 */
void gen(long dec, int pos, int *ret1, long *ret2) 
{
	long this_fact = fact(pos);
	for(int i=pos; i>-1; i--) 
	{
		long fact = this_fact * i;
		if(fact < dec) 
		{
			*ret1 = i;
			*ret2 = (dec - fact); 
			return; 
		}
	}
}

/* Determines the factoratic array representation of a given permutation number to
 * be used by an individual thread so it can determine which segment of the total
 * permutations it is responsible for calculating.
 */
void getFactoradic(long dec, long len, int *arr) 
{
	int next_digit, j=0; 
	long next_num, num=dec;
	for(int i=len-1; i>-1; i--) 
	{
		gen(num, i, &next_digit, &next_num); 
		arr[j++] = next_digit;  
		num = next_num;  
	}
}

int main(int argc, char* argv[])
{
	ifstream file (argv[1]);
	int numTrials;
	file >> numTrials;

	for (int j=0; j<numTrials; j++)
	{
 		clock_t start;
		clock_t end;

		start = clock();

	  	int maxWeight, numItems, usedWeight;  
	    // initialize arrays to numItems
	    file >> numItems;
	    file >> maxWeight;

	    // take in this round's values and weights
	   	int values[numItems], weights[numItems];
	    for (int i = 0; i < numItems; i++) file >> values[i];
	    for (int i = 0; i < numItems; i++) file >> weights[i];
	    
		int index[numItems]; // because one must get all the permutations on the indices
		for (int i=0; i<numItems; i++) index[i] = i;

		int bestItems[numItems];
		for (int i=0; i<numItems; i++) bestItems[i] = -1;

		int maxValueSoFar = 0;

		int overallMaxValue = 0;
		int overallUsedWeight = 0;
		int overallBestItems[numItems];

		int threadCount;
		long chunkSize;
	
		#pragma omp parallel firstprivate(index, bestItems, maxValueSoFar, usedWeight) shared(overallMaxValue, overallUsedWeight, overallBestItems)
		{
			int tid = omp_get_thread_num();
			threadCount = omp_get_num_threads();
			chunkSize = fact(numItems)/threadCount;
			long startPermutation = (chunkSize * tid) + 1;
			long counter = 0;

			int *indicies = new int[numItems];
			int *nums = new int[numItems];
			for(int i = 0;i < numItems;i++) 
				nums[i] = i;
			
			getFactoradic(startPermutation, numItems, indicies);

			/* turn the factoradic into a permutation */
			for(int i=0; i<numItems; i++) 
			{
				index[i] = nums[indicies[i]];
				for(int j=indicies[i]; j<numItems; j++) 
					nums[j] = nums[j+1]; 
				nums[numItems-1] = 0; 
			} 

			/* testing permutation generation */
			#pragma omp critical(print)
			{
				cout << "Thread: " << tid << "; permutation number: " << startPermutation << "; startPermutation: ";
				cout << "[";
				for (int i = 0; i < numItems; i++)
					cout << index[i] << ",";
				cout << "]" << endl;
			}

			do 
			{
				int curWeight = 0;
				int curValue = 0;
				int thisRoundItems[numItems];
				for (int i=0; i<numItems; i++) thisRoundItems[i] = -1;

				for (int i = 0; i < numItems; i++)
				{
					if (curWeight + weights[index[i]] <= maxWeight)
					{
						curWeight += weights[index[i]];
						curValue += values[index[i]];
						thisRoundItems[i] = index[i];
					}
					else break;
				}

				if (curValue > maxValueSoFar) 
				{
					maxValueSoFar = curValue;	
					usedWeight = curWeight;
					for (int i = 0; i < numItems; i++)
					{
						bestItems[i] = thisRoundItems[i];
					}
				}
			} while (next_permutation(index, index+numItems) && counter++ < chunkSize);

			#pragma omp critical(maxValue)
			{
				if (maxValueSoFar > overallMaxValue)
				{
					overallMaxValue = maxValueSoFar;
					overallUsedWeight = usedWeight;
					for (int i = 0; i < numItems; i++)
					{
						overallBestItems[i] = bestItems[i];
					}
				}
			}

			#pragma omp critical(print)
			{
				cout << "TID: " << tid << "'s best is: " << maxValueSoFar << " and ends at: ";
				cout << "[";
				for (int i=0; i<numItems; i++) 
					cout << index[i] << ",";
				cout << "], with a counter of " << counter << endl;
			}
		}

		end = clock();
		
		/** 
		 * Printing
		 */
		
		cout << "Trial number: " << j+1 << endl;
		cout << "Number of items: " << numItems << endl;
		cout << "Max capacity: " << maxWeight << endl;
		cout << "Max permutations: " << fact(numItems) << endl;
		cout << "Worker chunk size: " << chunkSize << endl;
		cout << "It took " << ((float)(end-start))/CLOCKS_PER_SEC << " seconds"  << endl;

	  	cout << "Values:  ";
	    for (int i=0; i<numItems; i++) cout << values[i] << " ";
	  	cout << endl;

	  	cout << "Weights: ";
	  	for (int i=0; i<numItems; i++) cout << weights[i] << " ";
	  	cout << endl;

	  	cout << "Indices: ";
	  	for (int i=0; i<numItems; i++) cout << i << " ";
	  	cout << endl;

		cout << "Overall best items: ";
		for (int i=0; i<numItems; i++) 
			if (overallBestItems[i] != -1) 
				cout << overallBestItems[i] << " ";
		cout << endl;

		cout << "Weight used: " << overallUsedWeight << endl;
		cout << "Total value: " << overallMaxValue << endl << endl;

	}
	return 0;
}
