
#include<iostream>
#include<fstream>
#include<string.h>
#include<sstream>//wherever a stringstream pops up, it is to convert a multi-digit number to a string or vice versa
#include"math.h"
#include<stdlib.h>
#include <cuda.h>
#include<time.h>

#include<sys/time.h> // Used for timing this.
#include<unistd.h> // Used for timing this.

#include<algorithm>//needed for next_permutation
#include<climits>//needed for MAX_INT

__device__ __host__ void convertFact(unsigned long long, short*);
__device__ __host__ void orderPermutation(short*, unsigned long long, int);
__device__ __host__ unsigned long long factorial(unsigned long long);

using namespace std;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
template<class _Ty1, class _Ty2> __device__
	bool prayer(const _Ty1& _Left, const _Ty2& _Right)
{	// test if _Left < _Right and operator< is strict weak ordering
	//	cout <<"!!" << endl;
	if (!(_Left < _Right))
		return (false);
	else if (_Right < _Left)
		;
	//_DEBUG_ERROR2("invalid operator<", _File, _Line);
	return (true);
}

__device__ void swap(short* a, short* b)
{
	//cout <<"swap!!" << endl;
	short temp = *a;
	*a = *b;
	*b = temp;
}

__device__ void reverse(short* a, short* b)
{
	//cout <<"reverse!!" << endl;
	b--;
	while(a < b)
	{
		swap(a,b);
		a++;
		b--;
		//cout << "swapping: " << *a << " with " << *b << endl;
	}
}

__device__ bool nextPerm(short* _First, short* _Last)
{	// permute and test for pure ascending, using operator<
	short* _Next = _Last;
	if (_First == _Last || _First == --_Next)
		return (false);

	for (; ; )
	{	// find rightmost element smaller than successor
		//	cout <<"!!" << endl;
		short* _Next1 = _Next;
		if (prayer(*--_Next, *_Next1))
		{	// swap with rightmost element that's smaller, flip suffix
			short* _Mid = _Last;
			for (; !prayer(*_Next, *--_Mid); )
				;
			swap(_Next, _Mid);
			reverse(_Next1, _Last);
			return (true);
		}

		if (_Next == _First)
		{	// pure descending, flip all
			reverse(_First, _Last);
			return (false);
		}
	}
}
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////




//returns the factorial for the given number
//x: the index for which factorial number you want.
//returns: x!
unsigned long long factorial(unsigned long long x)
{
	if(x == 1)
		return 1;
	else
		return x * factorial(x-1);
}
//converts a number into base factorial
//num: the number to convert to base factorial
//digits: a storage array to store the digits of the base factorial number
//numbers are stored in reverse order (so the 2nd digit is in position 1, the third in 2, etc.
//digits[0] will contain the length of the number in digits, since the first number of a base factorial number is always 0
__device__ __host__ void convertFact(unsigned long long num, short* digits)
{
	int numDigits = 1;//there is always a spare 0 in these numbers
	while(num > 0)
	{
		digits[numDigits] = num % (numDigits + 1);
		numDigits++;
		num /= numDigits;
	}
	digits[0] = numDigits;//because the first digit is always zero, we will store the length of the array in the 0th slot
}
//returns the array transposed to the nth permutation after the given ordering
//toOrder: the set for which you would like to define the nth permutation
//m: the numbered permutation to be stored in toOrder
//size: the size of the array toOrder
//warning: gives unpredictable behavior if n is > the number of unique permutations for toOrder
__device__ __host__ void orderPermutation(short* toOrder, unsigned long long n, int size)
{
	short swaps[100];
	convertFact(n, swaps);
	int location = size - swaps[0];//accounts for leading zeros
	int loc = swaps[0] - 1;//used to iterate through the digits of the factoradic number
	while(loc > 0)
	{
		int temp = toOrder[location + swaps[loc]];
		for(int x = location+swaps[loc]; x > location; x--)//moves all the other numbers up
		{
			toOrder[x] = toOrder[x - 1];
		}
		toOrder[location] = temp;
		location++;
		loc--;
	}

}

__global__ void permute(int* deviceWeights, int* deviceValues, short* deviceItems, long long* devicePermStartIndecies, int* deviceBestValueArray,long long* deviceBestPermArray, int deviceNumItems, int threadsPerBlock)
{


	int id = blockIdx.x * threadsPerBlock + threadIdx.x;

	short* items = deviceItems + (id * deviceNumItems);
	for(int index = 0; index < deviceNumItems; index++)
	{
		items[index] = index;
	}
	
	long long index;

	int totSum;
	int totWeight;

	long long bestPerm = 0;
	int bestValue = 0;

	float sectionRatio = (float)1.0/threadsPerBlock;
	long long block_Perms = devicePermStartIndecies[blockIdx.x + 1] - devicePermStartIndecies[blockIdx.x];
	long long start_Perm = (sectionRatio * threadIdx.x) * block_Perms;
	long long end_Perm = (sectionRatio * (threadIdx.x + 1)) * block_Perms;

	orderPermutation(items, devicePermStartIndecies[blockIdx.x] + start_Perm, deviceNumItems);
	
	int maxWeight = (deviceNumItems * 10)/2;


	for(index = devicePermStartIndecies[blockIdx.x] + start_Perm ; index < devicePermStartIndecies[blockIdx.x] + end_Perm ; index++)
	{
			
		totSum = 0;
		totWeight = 0;
		int i = 0;
		for(int w = 0; w < deviceNumItems; w++)
		{

			totWeight = totWeight + deviceWeights[items[w]];
			if(totWeight > maxWeight)
			{
				break;
			}
			totSum = totSum + deviceValues[items[w]];
				
			i++;
		}

			
		if(totSum > bestValue)
		{
			bestValue = totSum;
			bestPerm = index;
		
		}

		
		nextPerm(items, items + deviceNumItems);
			
		
	}

	deviceBestValueArray[id] = bestValue;
	deviceBestPermArray[id] = bestPerm;



}


int main(int argc, char* argv[])
{

	struct timeval startTime, endTime;
	gettimeofday(&startTime, NULL);

	if(argc != 5)
	{
		cout<<"You have enetered and invalid argument list"<<endl;
		cout<<"Required(number of Items) (seed) (number of blocks) (number of threads per block)"<<endl;
	}

	stringstream arg1(argv[1]);
	int numItems;
	arg1 >> numItems;

	stringstream arg2(argv[2]);
	int randomSeed;
	arg2 >> randomSeed;

	srand(randomSeed);

	
	stringstream arg3(argv[3]);
	int numBlocks;
	arg3 >> numBlocks;


	stringstream arg4(argv[4]);
	int numThreads;
	arg4 >> numThreads;
	

	long long totalThreads = numBlocks * numThreads;


	int maxWeight = (numItems *10) / 2;


	long long* permStartIndecies = (long long*)malloc((numBlocks + 1) * sizeof(long long));

	long long numPerms = factorial(numItems);

	double sectionRatio = double(1)/numBlocks;

	for(int index = 0; index < numBlocks + 1; index++)
	{
		permStartIndecies[index] = numPerms * (sectionRatio * index);
	}
	

	    // take in this round's values and weights
	int* values = (int*)malloc(numItems * sizeof(int));
	int* weights =(int*)malloc(numItems * sizeof(int));
	

	cout<<numItems<<endl;
	cout<<maxWeight<<endl;
	for(int index = 0; index < numItems; index++)
	{
		values[index] = rand() % 30;
		cout<<values[index]<<" ";
	}
	cout<<endl;
	for(int index = 0; index < numItems; index++)
	{
		weights[index] = rand() % 30;
		cout<<weights[index]<<" ";
	}
	cout<<endl;
	
	int* deviceValues;
	int* deviceWeights;
	cudaMalloc((void**)&deviceValues, numItems*sizeof(int));
	cudaMalloc((void**)&deviceWeights, numItems*sizeof(int));

	cudaMemcpy(deviceValues, values, numItems*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(deviceWeights, weights, numItems*sizeof(int), cudaMemcpyHostToDevice);

	short* deviceItems;
	cudaMalloc((void**)&deviceItems, (totalThreads * numItems)*sizeof(short)); 

	long long* devicePermStartIndecies;
	cudaMalloc((void**)&devicePermStartIndecies, (numBlocks +1)*sizeof(long long));
	cudaMemcpy(devicePermStartIndecies, permStartIndecies, (numBlocks +1)*sizeof(long long), cudaMemcpyHostToDevice);
	
	int* deviceBestValueArray;
	long long* deviceBestPermArray;
	cudaMalloc((void**)&deviceBestValueArray,(totalThreads) * sizeof(long long));
	cudaMalloc((void**)&deviceBestPermArray,(totalThreads) * sizeof(long long));
	


	////entering the parallel section
	permute<<<numBlocks,numThreads>>>(deviceWeights, deviceValues, deviceItems, devicePermStartIndecies, deviceBestValueArray, deviceBestPermArray, numItems, numThreads);


	long long* bestPermArray = (long long*)malloc((totalThreads) * sizeof(long long));
	int* bestValueArray = (int*)malloc((totalThreads) * sizeof(int));

	cudaMemcpy(bestPermArray, deviceBestPermArray, (totalThreads) * sizeof(long long), cudaMemcpyDeviceToHost);
	cudaMemcpy(bestValueArray, deviceBestValueArray, (totalThreads) * sizeof(int), cudaMemcpyDeviceToHost);
	

	int finalValue;
	unsigned long long finalPerm = 0;
	int tempValue = 0;
	for(int index = 0; index < totalThreads; index++)
	{
		if(bestValueArray[index] > tempValue)
		{
			tempValue = bestValueArray[index];
			finalPerm = bestPermArray[index];
		}
	}
	finalValue = tempValue;

	short* permArray = new short[numItems];
	for(int index = 0; index < numItems; index++)
	{
		permArray[index] = index;
	}

	orderPermutation(permArray, finalPerm, numItems);
	
	int checkWeight = 0;
	for(int index = 0; index < numItems; index++)
	{
		checkWeight = checkWeight + weights[permArray[index]];
		//cout<<checkWeight<<endl;
		if(checkWeight > maxWeight)
		{
			break;
		}
		cout <<  permArray[index]<< ", ";
	}

	cout<< "best value for theft: "<< finalValue<<endl;
	
	

	gettimeofday(&endTime, NULL);
	long timeDelta, startSeconds, startUSeconds, stopSeconds, stopUSeconds, startTotal, stopTotal;
	startSeconds = startTime.tv_sec;
	stopSeconds = endTime.tv_sec;
	startUSeconds = startTime.tv_usec;
	stopUSeconds = endTime.tv_usec;
	startTotal = (startSeconds * 1000) + (startUSeconds / 1000);
	stopTotal = (stopSeconds * 1000) + (stopUSeconds / 1000);


	timeDelta = stopTotal - startTotal;
	cout << "Time: " << timeDelta << " milliseconds" << endl;
	

	
}
