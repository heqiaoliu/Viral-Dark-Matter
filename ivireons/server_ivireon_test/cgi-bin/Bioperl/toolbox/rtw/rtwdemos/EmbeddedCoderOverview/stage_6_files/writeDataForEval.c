/* Copyright 2007 The MathWorks, Inc. */
#ifndef __WRITEDATAFOREVAL
#define __WRITEDATAFOREVAL

#include "rtwtypes.h"
#include "stdio.h"
extern real_T logData[2001];

void writeDataForEval(void)
{
	/* This file writes out the throttle position calculated by the
	 *  plant for comparison with the Simulink model */
	FILE *fp;
	int inx = 1;
	if ((fp = fopen("eclipseData.m","w")) == NULL)
	{
		printf("Error in opening output file\n");
	}
	else
	{
		fprintf(fp,"%%Data from Eclipse run\n");
		fprintf(fp,"throttlePos = [%f,...\n",logData[0]);
		while (inx < 2001)
		{   
			fprintf(fp,"               %f,...\n",logData[inx]);
			inx++;
		}
		fprintf(fp,"              ];\n");
	}
	fclose(fp);
}

#endif


