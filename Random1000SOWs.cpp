/* LakeProblem_MOEA.cpp
 
 Riddhi Singh, Nov, 2013
 The Pennsylvania State University
 rus197@psu.edu

 Generating 10,000 random states of the world for use by the random seed in the 
 optimization under stochastic uncertainty for the lake model.
 */

#include <iostream>
#include <fstream>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string>
#include <sstream>
#include <time.h>
#include <boost/random.hpp>
#include <boost/random/lognormal_distribution.hpp>
#include <algorithm>                            //for sorting
using namespace std;

#define PI 3.14159265358979323846
#define samples 10000
#define nDays 100

//initialize the stochastic term for the discount factor
#define dis_sigma 0.05
#define dis_mean 0.0

int main(int argc, char* argv[])
{
  string path           = "";
  string SOWheader      = "SOWs_Type";
  string ext            = ".txt";
  string outfilename;
  int nfiles  = 9;
  
  //define pollution flow parameters 
  
  double pol_mean [9]  = {0.01, 0.01, 0.01,
			  0.02, 0.02, 0.02,
			  0.03, 0.03, 0.03};
  double pol_sigma [9] = {0.00316227766, 0.00177827941, 0.001, 
			  0.00316227766, 0.00177827941, 0.001, 
			  0.00316227766, 0.00177827941, 0.001};
  cout<<pol_sigma[1]<<endl;
  for (int solfnum=0; solfnum<nfiles; solfnum++)
    {      
      //now open the output file and the file whose solutions are to be evaluated for these states of the world 
      string temp;
      ostringstream convert;
      convert << solfnum;
      temp = convert.str();

      outfilename = path + SOWheader + temp + ext;
      cout<<"The filename is " << outfilename <<endl;
      double ** rand_SOW = NULL;
      rand_SOW = new double* [samples];
      for (int j=0;j<samples;j++) {
	rand_SOW[j] = new double [nDays];
      }
      for (int j=0;j<samples;j++)
	{	for (int i=0;i<nDays;i++)
	    rand_SOW[j][i] = 0.0;
	}		 
      for (int j=0;j<samples;j++)
	{
	  //initialize the random walk for natural pollutin flow 
	  boost::mt19937 rng(j); 
	  boost::lognormal_distribution<double> lnd(pol_mean[solfnum], pol_sigma[solfnum]);
	  boost::variate_generator<boost::mt19937&, boost::lognormal_distribution<> > var_lognor(rng, lnd);
	  
	  for (int i=0;i<nDays;i++)
	    {
	      rand_SOW[j][i]  =var_lognor();
	    }
	}
      
      const char *outfname = outfilename.c_str();
      FILE *outfile;
      outfile   = fopen(outfname,"w");
      double trial;
	
      if (outfile==NULL) perror("Error opening file");
      else 
	{
	  for (int j=0;j<samples;j++)
	    {
	      //initialize the random walk for natural pollutin flow 
	      for (int i=0;i<nDays;i++)
		{
		  fprintf(outfile, "%.17g ", rand_SOW[j][i]);
		}
	      fprintf(outfile,"\n");
	    }
	  
	}
      fclose(outfile);
      
      for (int i=0;i<samples;i++) {
	delete [] rand_SOW[i];
      }
      delete [] rand_SOW;
    }
  return EXIT_SUCCESS;
}
  
