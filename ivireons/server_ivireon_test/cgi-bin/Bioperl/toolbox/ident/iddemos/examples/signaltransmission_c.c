/*   Copyright 2005-2008 The MathWorks, Inc. */
/*   $Revision: 1.1.8.3 $ $Date: 2008/04/28 03:17:20 $ */
/*   Written by Peter Lindskog. */

/* Include libraries. */
#include "mex.h"
#include <math.h>

/* Specify the number of outputs here. */
#define NY 1

/* State equations. */
void compute_dx(double *dx, int nx, double *x, double *u, double **p,
                const mxArray *auxvar)
{
    /* Declaration of model parameters and intermediate variables. */
    double *L, *C;      /* Model parameters.                  */
    double h, Lh, Ch;   /* Intermediate variables/parameters. */
    int    j;           /* Equation counter.                  */
    
    /* Retrieve model parameters. */
    L = p[0];   /* Inductance per unit length.  */
    C = p[1];   /* Capacitance per unit length. */
        
    /* Get and check FileArgument (auxvar). */
    if (mxGetNumberOfElements(auxvar) < 1) {
        mexErrMsgIdAndTxt("IDNLGREY:ODE_FILE:InvalidFileArgument",
                          "FileArgument should at least hold one element.");
    } else if (mxIsStruct(mxGetCell(auxvar, 0)) == false) {
        mexErrMsgIdAndTxt("IDNLGREY:ODE_FILE:InvalidFileArgument",
                          "FileArgument should contain a structure.");
    } else if (   (mxGetFieldNumber(mxGetCell(auxvar, 0), "N") < 0)
               || (mxGetFieldNumber(mxGetCell(auxvar, 0), "L") < 0)) {
        mexErrMsgIdAndTxt("IDNLGREY:ODE_FILE:InvalidFileArgument",
                          "FileArgument should contain a structure with fields 'N' and 'L'.");
    } else {
        /* Skip further error checking to obtain execution speed. */
        h = *mxGetPr(mxGetFieldByNumber(mxGetCell(auxvar, 0), 0, 
                     mxGetFieldNumber(mxGetCell(auxvar, 0), "L"))) / (0.5*((double) nx));
    }
    Lh = -1.0/(L[0]*h);
    Ch = -1.0/(C[0]*h);
    
    /* x[0]   : Current i_0(t).    */
    /* x[1]   : Voltage u_1(t).    */
    /* x[2]   : Current i_1(t).    */
    /* x[3]   : Voltage u_1(t).    */
    /* ...                         */
    /* x[Nx-2]: Current i_Nx-1(t). */
    /* x[Nx-1]: Voltage u_Nx(t).   */
    for (j = 0; j < nx; j = j+2) {
        if (j == 0) {
            /* First transmitter section. */
            dx[j]   = Lh*(x[j+1]-u[0]);
            dx[j+1] = Ch*(x[j+2]-x[j]);
        } else if (j < nx-3) {
            /* Intermediate transmitter sections. */
            dx[j]   = Lh*(x[j+1]-x[j-1]);
            dx[j+1] = Ch*(x[j+2]-x[j]);
        } else {
            /* Last transmitter section. */
            dx[j]   = Lh*(x[j+1]-x[j-1]);
            dx[j+1] = -Ch*x[j];
        }
    }
}

/* Output equation. */
void compute_y(double *y, int nx, double *x)
{
    /* y[0]: Voltage at the end of the transmitter. */
    y[0] = x[nx-1];
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
    double *x, *u, **p, *dx, *y, *t;
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
    
    /* Determine number of inputs and states. */
    nx = mxGetNumberOfElements(prhs[1]); /* Number of states. */
    nu = mxGetNumberOfElements(prhs[2]); /* Number of inputs. */
    
    /* Obtain double data pointers from mxArrays. */
    t = mxGetPr(prhs[0]);  /* Current time value (scalar). */
    x = mxGetPr(prhs[1]);  /* States at time t. */
    u = mxGetPr(prhs[2]);  /* Inputs at time t. */
    
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
    compute_dx(dx, nx, x, u, p, auxvar);
    
    /* Call function for output update. */
    compute_y(y, nx, x);
    
    /* Clean up. */
    mxFree(p);
}
