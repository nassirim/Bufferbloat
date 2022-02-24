#define _CRT_SECURE_NO_WARNINGS
#include <assert.h>             
#include <stdio.h>            
#include <stdlib.h>             
#include <math.h>               

#define  FALSE          0       
#define  TRUE           1      


int      zipf(double alpha, int n);  
double   rand_val(int seed);         

									 
int main(int argc , char * argv[])
{
	FILE   *fp;                   
	char   file_name[15]="zipf-file";           
	double alpha;                 
	double n;                     
	int    num_values;            
	int    zipf_rv;               
	int    i;                     

								 
	fp = fopen(file_name, "w");
	if (fp == NULL)
	{
		printf("ERROR in creating output file (%s) \n", file_name);
		exit(1);
	}
	
	if (argc=2 || argc>2 )
	{
	
		rand_val((int)atoi(argv[1]));

	 	alpha = atof(argv[2]);

		n = atoi(argv[3]);

		num_values = atoi(argv[4]);
	}
	else
	{
		printf("error in amount of argc \n");
	}	

		
	for (i = 0; i<num_values; i++)
	{
		zipf_rv = zipf(alpha, n);
		fprintf(fp, "%d \n", zipf_rv);
	}

	
	fclose(fp);
}


int zipf(double alpha, int n)
{
	static int first = TRUE;      
	static double c = 0;          
	double z;                    
	double sum_prob;              
	double zipf_value;            
	int    i;                     

								  
	if (first == TRUE)
	{
		for (i = 1; i <= n; i++)
			c = c + (1.0 / pow((double)i, alpha));
		c = 1.0 / c;
		first = FALSE;
	}

	do
	{
		z = rand_val(0);
	} while ((z == 0) || (z == 1));

	
	sum_prob = 0;
	for (i = 1; i <= n; i++)
	{
		sum_prob = sum_prob + c / pow((double)i, alpha);
		if (sum_prob >= z)
		{
			zipf_value = i;
			break;
		}
	}

	
	assert((zipf_value >= 1) && (zipf_value <= n));

	return(zipf_value);
}

double rand_val(int seed)
{
	const long  a = 16807;  
	const long  m = 2147483647;  
	const long  q = 127773;  
	const long  r = 2836;
	static long x;               
	long        x_div_q;         
	long        x_mod_q;         
	long        x_new;           

								
	if (seed > 0)
	{
		x = seed;
		return(0.0);
	}

	
	x_div_q = x / q;
	x_mod_q = x % q;
	x_new = (a * x_mod_q) - (r * x_div_q);
	if (x_new > 0)
		x = x_new;
	else
		x = x_new + m;

	
	return((double)x / m);
}
