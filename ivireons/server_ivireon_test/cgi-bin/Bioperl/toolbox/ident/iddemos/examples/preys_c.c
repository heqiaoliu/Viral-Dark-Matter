/*   Copyright 2005-2008 The MathWorks, Inc. */
/*   $Revision: 1.1.8.3 $ $Date: 2008/04/28 03:17:17 $ */
/*   Written by Peter Lindskog. */

/* Include libraries. */
#include "mex.h"
#include <math.h>

/* Specify the number of outputs here. */
#define NY 2

/* State equations. */
void compute_dx(double *dx, double t, double *x, double **p,
                const mxArray *auxvar)
{
    /* Retrieve model parameters. */
    double *p1, *p2, *p3, *p4;
    p1 = p[0];   /* Survival factor, species 1. */
    p2 = p[1];   /* Death factor, species 1.    */
    p3 = p[2];   /* Survival factor, species 2. */
    p4 = p[3];   /* Death factor, species 2.    */
    
    /* x[0]: Prey species 1. */
    /* x[1]: Prey species 2. */
    dx[0] = p1[0]*x[0]-p2[0]*(x[0]+x[1])*x[0];
    dx[1] = p3[0]*x[1]-p4[0]*(x[0]+x[1])*x[1];
}

/* Output equations. */
void compute_y(double *y, double t, double *x, double **p,
               const mxArray *auxvar)
{
    /* y[0]: Prey species 1. */
    /* y[1]: Prey species 2. */
    y[0] = x[0];
    y[1] = x[1];
}



/*----------------------------------------------------------------------- *
   DO NOT MODIFY THE CODE BELOW UNLESS YOU NEED TO PASS ADDITIONAL
   INFORMATION TO COMPUTE_DX AND COMPUTE_Y
 
   To add extra arguments to compute_dx and compute_y (e.g., size
   information), modify the definitions above and calls below.
 *-----------------------------------------------------------------------*/

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    /* Declaration of input and output arguments. */
    double *x, **p, *dx, *y, *t;
    int     i, np, nu, nx;
    const mxArray *auxvar = NULL; /* Cell array of additional data. */
    
    if (nrhs < 3) {
        mexErrMsgIdAndTxt("IDNLGREY:ODE_FILE:InvalidSyntax",
        "At least 3 inputs expected (t, u, x).");
    }
    
    /* Determine if auxiliary variables were passed as last input.  */
    if ((nrhs > 3) && (mxIsCell(prhs[nrhs-1]))) {
        /* Auxiliary variables were passed as input. */
        auxvar = prhs[nrhs-1];
        np = nrhs - 4; /* Number of parameters (could be 0). */
    } else {
        /* Auxiliary variables were not passed. */
        np = nrhs - 3; /* Number of parameters. */
    }
    
    /* Determine number of states. */
    nx = mxGetNumberOfElements(prhs[1]); /* Number of states. */
    
    /* Obtain double data pointers from mxArrays. */
    t = mxGetPr(prhs[0]);  /* Current time value (scalar). */
    x = mxGetPr(prhs[1]);  /* States at time t. */
    
    p = mxCalloc(np, sizeof(double*));
    for (i = 0; i < np; i++) {
        p[i] = mxGetPr(prhs[3+i]); /* Parameter arrays. */
    }
    
    /* Create matrix for the return arguments. */
    plhs[0] = mxCreateDoubleMatrix(nx, 1, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(NY, 1, mxREAL);
    dx      = mxGetPr(plhs[0]); /* State derivative values. */
    y       = mxGetPr(plhs[1]); /* Output values. */
    
    /*
      Call the state and output update functions.
      
      Note: You may also pass other inputs that you might need,
      such as number of states (nx) and number of parameters (np).
      You may also omit unused inputs (such as auxvar).
      
      For example, you may want to use orders nx and nu, but not time (t)
      or auxiliary data (auxvar). You may write these functions as:
          compute_dx(dx, nx, nu, x, u, p);
          compute_y(y, nx, nu, x, u, p);
    */
    
    /* Call function for state derivative update. */
    compute_dx(dx, t[0], x, p, auxvar);
    
    /* Call function for output update. */
    compute_y(y, t[0], x, p, auxvar);
    
    /* Clean up. */
    mxFree(p);
}
