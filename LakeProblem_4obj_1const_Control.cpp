/* LakeProblem_4Obj_1Const_Stoch.cpp
   
   Riddhi Singh, May, 2014
   The Pennsylvania State University
   rus197@psu.edu

   Adapted by Tori Ward, July 2014 
   Cornell University
   vlw27@cornell.edu
   
   Adapted by Yu Li, September 2014 
   Politecnico di Milano
   likymice@gmail.com

   A multi-objective represention of the lake model from Carpenter et al., 1999
   This simulation is designed for optimization with either Borg or the MOEAFramework.
   
   Stochasticity is introduced by:
   1. Natural variability around anthropogenic pollution flow, which is represented by an 
   SOW file.  SOW4.txt presents the known distribution (mean of 0.02 and log10(variance) of -5.5)
    and SOW6.txt presents a harsher distribution with a higher mean P level (0.03) 
    and more variability (log10(variance) of -5).  

   Inputs 
   Parameters related to lake
      b : proportion of phosphorous retained in the lake each year    
      q : steepness of the sigmoid curve, large values give a steeper curve

   Parameters related to utility function
      delta   : discount rate
      alpha   : utility from pollution
      beta    : eutrophic cost

   State variables 
     lake_stateX : Phosphorous concentration at previous time step

   Decision Vector 
      vars : anthropogenic pollution flow at previous time step (this was aval in R and MATLAB versions)

  Outputs
     Utility and discounted at a given time step
     utility : utility at every time step
     npv_util: discounted utility - this is also the objective function
     
     Updated lake_stateX 

 Objectives
 1. minimize the maximum Phosphorous averaged over all states of the world in a time period
 2. maximize expected benefit from pollution
 3. maximize the probability of meeting an inertia constraint
 4. maximize Reliability

Additional features:
1. Bounds for decision vector (0,0.1)
2. Precision - up to 3 digits
3. Annual control -100 total decision variables
*/

#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string>
#include <sstream>
#include "moeaframework.h"
using namespace std;

#define PI      3.14159265358979323846
#define nDays   100
#define q 	    2
#define b 	    0.42
#define alpha   0.4
#define beta    0.08
#define delta   0.98
#define samples 100

//define reliability related parameters
#define pcrit 0.5
#define reliab_thres 0.85  
#define inertia_thres (-0.02) //left in as it will be necessary for probability calculations

//decision space control and precision control parameters
//int interval = 5; we no longer have intervals since this is an annual control experiment
int precis   = 3;                      

double passInitX= 0;

int nobjs;
int nvars;
int nconsts;
double nat_flowmat [10000][nDays]; // create a matrix of [ 10000 x nDays ]

void lake_problem(double* vars, double* objs, double* consts) 
{
  // opt 1 - declare the cumulated step indicators (4) 
  
    //run the stochastic case now for objective function 3
  double * oftime1 = new double [nDays]  ;    // Phosphorus in the lake
  double * ofs2    = new double [samples];    // benefit from pollution
  double * ofs3    = new double [samples];    // reliability, Prob(Ph>Pcrit)
  double * ofs4    = new double [samples];    // inertia, Prob(maintain inertia)

  // opt 2 - initialize the indicators 
  for (int sample=0; sample<samples;sample++)
    {
      ofs2[sample]    = 0.0;
      ofs3[sample]    = 0.0;
      ofs4[sample]    = 0.0;
    }
 
  for (int day=0; day<nDays; day++)
  {
    oftime1[day] = 0;
  }
  
  // opt 3 - define and initialize the inflow line values stochastically
  
  int linetouse [samples];
  srand (time(NULL)); //gives PRNG a seed based on time
  for (int sample=0; sample<samples;sample++) {
    //pick a random number based on time
    //choose 100 of 10,000 available inflow value lines
    linetouse[sample] = rand() % 10000;
  }
  
   
  // opt 4 - simulate the dynamic lake evolution for all samples 
  for (int sample=0; sample<samples;sample++)
    {   
	
	// opt 4.1 - stochastically draw the natural flow time-series
	
      double *nat_flow = new double [nDays];
      int index = linetouse[sample];
      // get the random natural flow from the States of the world file
      //each line of SOW file covers 100 days of inflow
      for (int i=0;i<nDays;i++){
	       nat_flow[i] = nat_flowmat[index][i]; 
      }
       
    // 4.2 - declare the state variables and decision variable (usevars)      
      int i;
      double * lake_stateX = new double [nDays];
      double * benefit     = new double [nDays];
      double * poll        = new double [nDays];
      double * phos        = new double [nDays];
      double * pol_flow    = new double [nDays];
      double * usevars     = new double [nDays];
      double * change_dec  = new double [nDays - 1];
     
    // opt 4.3 - initialize variables
      for (i=0; i < nDays; i++)
	       { lake_stateX[i] = 0.0;
	         benefit[i]     = 0.0;
	         poll[i]        = 0.0;
	         phos[i]        = 0.0;
	         usevars[i]     = 0.0;
	        }

      for (i=0; i < (nDays -1); i++)
		  {
			change_dec[i] = 0.0;
		  }

            
      for (i=0; i<nDays; i++) 
	  {
		usevars[i] = vars[i];	 
	// opt 4.4 - calculate the change in decision variables from one time step to 
	//       the next to determine inertia .
		if (i>0) change_dec[i-1] = vars[i]-vars[i-1];

	  }   
  
    // opt 4.5 - now add natural pollution
      for (i=0; i < nDays; i++)
	    {
	        pol_flow[i] = usevars[i] + nat_flow[i];
	    }

      // round off to the required precision
      for (i=0; i<nDays; i++)
	    {
	       pol_flow[i] = round(pol_flow[i]*pow(10,(double)precis))/(pow(10,(double)precis));
	       usevars[i]  = round(usevars[i]*pow(10,(double)precis))/(pow(10,(double)precis));
	    }

      for (i=0; i<(nDays-1); i++)
        {
           change_dec[i] = round(change_dec[i]*pow(10,(double)precis))/(pow(10,(double)precis)); //round to required precise
        }


    // opt 4.6 - implementation of the lake model ( see Carpenter et al. 1999 )
	
      for (i=0; i<nDays; i++)
	    {
		   // update the state variables 
	       if (i==0)
	        {
	          lake_stateX[i] = passInitX*(1-b)+pow(passInitX,q)/(1+pow(passInitX,q))+pol_flow[i];
              oftime1[i]     = oftime1[i] + lake_stateX[i];
	        }else
	       {
	          lake_stateX[i] = lake_stateX[i-1]*(1-b)+(pow(lake_stateX[i-1], q))/(1+pow(lake_stateX[i-1],q))+pol_flow[i];
              oftime1[i]     = oftime1[i] + lake_stateX[i];
	        }

	      benefit[i] = alpha*usevars[i];
	      phos[i]    = beta*pow(lake_stateX[i], 2);
	      poll[i]    = alpha*usevars[i];	    
	    }
      
    // opt 4.7 - update the step indicators for each samples 
	
      for (i=0; i<nDays; i++)
	    {
		  ofs2[sample] = ofs2[sample] + benefit[i]*pow(delta,(i)); 	     
	      //estimate the reliability matrix
	      if (lake_stateX[i] < pcrit)
	         ofs3[sample] = ofs3[sample] + 1;
	    }
     
       for (i=0; i<(nDays-1); i++) 
        {
          //estimate the inertia matrix
          if (change_dec[i] > inertia_thres)
          ofs4[sample] = ofs4[sample]+1;
        }      

	// opt 4.8 - clear memory 
 	
      delete [] lake_stateX;
      delete [] benefit;
      delete [] poll;
      delete [] phos;
      delete [] pol_flow;
      delete [] nat_flow;
      delete [] usevars;
      delete [] change_dec;
    }

  // opt 5 - create dummy variables for running tally of values summed over all samples
  
  double dumofs1 = -9999;//initialize to infeasibly low value for future search for maximum
  double dumofs2 = 0.0;
  double dumofs3 = 0.0;
  double dumofs4 = 0.0;

  for(int day=0; day<nDays; day++)
  {
    oftime1[day] = oftime1[day]/samples; // mean ? 
  }

  for(int day=0;day<nDays;day++)
  {
    if(oftime1[day]>dumofs1)
      dumofs1 = oftime1[day]; // max concentration? 
  }

  for (int sample=0;sample<samples;sample++)
   {
    dumofs2  = dumofs2 + ofs2[sample];   // Benefit of pollution
    dumofs3  = dumofs3 + ofs3[sample];   // Reliability estimator
    dumofs4  = dumofs4 + ofs4[sample];   // Inertia estimator
   }

  // opt 6 - Calculate objectives
  objs[0] = dumofs1;          //maximum daily phosphorus averaged over states of world
  objs[1] = dumofs2/samples;  //expected benefit from pollution
  
  double prob_inertia_maintained = dumofs4/((nDays - 1)*samples);
  
  if (prob_inertia_maintained > 1)
    exit(EXIT_FAILURE);

  objs[2] = prob_inertia_maintained;  //probability inertia stays below threshold

  double reliability  = dumofs3/(nDays*samples);
  if (reliability>1)
    exit(EXIT_FAILURE);

  if (reliability>reliab_thres){
     consts[0]= 0.0;
  }else{
   consts[0] = reliab_thres-reliability;
  }
  
  objs[3]  = reliability; //probability the lake is not tipped
  
  objs[0]    =  objs[0];     //want to minimize phosphorous in the lake
  objs[1]    = -objs[1];     //want to maximize expected benefit from pollution
  objs[2]    = -objs[2];     //want to maximize the probability of maintaining inertia
  objs[3]    = -objs[3];     //want to maximize reliability

  delete [] oftime1;
  delete [] ofs2;
  delete [] ofs3;
  delete [] ofs4;

}

// ********************

int main(int argc, char* argv[]) 
{
  nvars   = nDays;
  nobjs   = 4;
  nconsts = 1;
  
  for (int i=0;i<10000;i++){   //this is 10,000 to match nat_flowmat's size
    for (int j=0;j<nDays;j++){
      nat_flowmat[i][j] = 0.0; 
	}
  }
  
  FILE * myfile;
  myfile = fopen("SOWs_Type6.txt","r");
  
  int linenum =0;
  int maxSize =5000;
  
  if (myfile==NULL){
    perror("Error opening file");
  }else{
      char buffer [maxSize];
      while ( fgets(buffer, maxSize, myfile)!=NULL) 
	     { linenum++;
	         if (buffer[0]!='#')
	       {
	           char *pEnd;
	           char *testbuffer = new char [maxSize];
	             for (int i=0; i <maxSize; i++)
		              testbuffer[i] = buffer[i];
  
	           for (int cols =0;cols<nDays;cols++)                // use nDays not nvars, since now they are different
		         {
		            nat_flowmat[linenum-1][cols] = strtod(testbuffer, &pEnd);
		            testbuffer  = pEnd;	
		          }				
	        }
	      }
    }
	
  fclose(myfile);
  
  double vars[nvars];
  double objs[nobjs];
  double consts[nconsts];
 
  MOEA_Init(nobjs, nconsts);
  
  while (MOEA_Next_solution() == MOEA_SUCCESS) {
    MOEA_Read_doubles(nvars, vars);
    lake_problem(vars, objs, consts);
    MOEA_Write(objs, consts);
  }
  
  MOEA_Terminate();
  return EXIT_SUCCESS;
}
