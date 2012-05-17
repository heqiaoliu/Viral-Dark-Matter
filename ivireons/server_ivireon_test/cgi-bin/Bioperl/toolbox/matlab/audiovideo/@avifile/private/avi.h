/* Copyright 2003 The MathWorks, Inc. */

/* $Revision: 1.1.6.2 $  $Date: 2007/07/26 19:29:52 $ */

#include <windows.h>
#include <vfw.h>
#include "mex.h"

#ifdef __cplusplus
   extern "C"
   {
#endif


void aviopen(int nlhs,
                 mxArray *plhs[],
                 int nrhs,
                 const mxArray *prhs[]);

 
void addframe(int nlhs,
                 mxArray *plhs[],
                 int nrhs,
                 const mxArray *prhs[]);

void aviclose(int nlhs,
                 mxArray *plhs[],
                 int nrhs,
                 const mxArray *prhs[]);


#ifdef __cplusplus
    }   /* extern "C" */
#endif

