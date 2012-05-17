/* Copyright 2005-2007 The MathWorks, Inc. */

/* $Revision: 1.1.6.2 $ */

#include <stdio.h>
#include "fault.h"


void initFaultCounter(unsigned int *counter)
{
    *counter = 0;
}

void openLogFile(void **fid)
{
    FILE *fptr;
    fptr = fopen("sldemo_lct_fault.log", "wt");
    if (fptr==NULL) {
        MY_PRINT("Cannot open the file 'sldemo_lct_fault.log'\n");
    }
    *fid = fptr;
}


void incAndLogFaultCounter(void *fid, unsigned int *counter, double time)
{
    FILE *fptr = (FILE *) fid;
    
    (*counter)++;
    if (fptr==NULL) {
        MY_PRINT("Cannot write to the file 'sldemo_lct_fault.log'\n");
        return;   
    }
    
    (void) fprintf(fptr, "Fault %d detected at %g s\n", *counter, time);
        
}


void closeLogFile(void **fid) 
{
    FILE *fptr = (FILE *) *fid;
       
    if (fptr==NULL) {
        MY_PRINT("Cannot close the file 'sldemo_lct_fault.log'\n");
        return;
    }
    
    fclose(fptr);
}
