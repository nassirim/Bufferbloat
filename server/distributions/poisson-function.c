#include <stdio.h>
#include <string.h>
#include <stdlib.h>            
#include <math.h> 



int    poisson(double x);       
double expon(double x);        
double rand_val(int seed);      

								
int main(int argc ,char * argv[])
{
	FILE     *fp;                
	char     file_name[15]="poisson-file" ;     
	char     temp_string[10];    
	double   lambda;              
	int      pois_rv;             
	int      num_values;          
	int      i;                   

								  

	fp = fopen(file_name, "w");
	if (fp == NULL)
	{
		printf("ERROR in creating output file (%s) \n", file_name);
		exit(1);
	}

	
	rand_val((int)atoi(argv[1]));

	lambda = atof(argv[2]);

	num_values = atoi(argv[3]);
	
	for (i = 0; i<num_values; i++)
	{
		pois_rv = poisson(1.0 / lambda);
		fprintf(fp, "%d \n", pois_rv);
	}

	
	printf("-------------------------------------------------------- \n");
	printf("-  Done! \n");
	printf("-------------------------------------------------------- \n");
	fclose(fp);
}


int poisson(double x)
{
	int    poi_value;            
	double t_sum;                 

								 
	poi_value = 0;
	t_sum = 0.0;
	while (1)
	{
		t_sum = t_sum + expon(x);
		if (t_sum >= 1.0) break;
		poi_value++;
	}

	return(poi_value);
}


double expon(double x)
{
	double z;                     
	double exp_value;             

								  
	do
	{
		z = rand_val(0);
	} while ((z == 0) || (z == 1));

	
	exp_value = -x * log(z);

	return(exp_value);
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
