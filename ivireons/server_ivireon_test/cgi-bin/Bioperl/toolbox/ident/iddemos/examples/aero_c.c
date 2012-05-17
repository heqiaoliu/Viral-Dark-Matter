/*   Copyright 2005-2010 The MathWorks, Inc. */
/*   $Revision: 1.1.8.1 $ $Date: 2010/03/22 03:48:37 $ */
/*   Written by Peter Lindskog. */

/* Include libraries. */
#include "mex.h"
#include <math.h>

/* Specify the number of outputs here. */
#define NY 5

/* State equations. */
void compute_dx(double *dx, double *x, double *u, double **p)
{
    /* Retrieve model parameters. */
    double *F, *M, *C, *d, *A, *I, *m, *K;
    F = p[0];   /* Aerodynamic force coefficient.    */
    M = p[1];   /* Aerodynamic momentum coefficient. */
    C = p[2];   /* Aerodynamic compensation factor.  */
    d = p[3];   /* Body diameter.                 */
    A = p[4];   /* Body reference area.           */
    I = p[5];   /* Moment of inertia, x-y-z.         */
    m = p[6];   /* Mass.                     */
    K = p[7];   /* Feedback gain.                    */
    
    /* x[0]: Angular velocity around x-axis. */
    /* x[1]: Angular velocity around y-axis. */
    /* x[2]: Angular velocity around z-axis. */
    /* x[3]: Angle of attack. */
    /* x[4]: Angle of sideslip. */
    dx[0] = 1/I[0]*(d[0]*A[0]*(M[0]*x[4]+0.5*M[1]*d[0]*x[0]/u[4]+M[2]*u[0])*u[3]-(I[2]-I[1])*x[1]*x[2])+K[0]*(u[5]-x[0]);
    dx[1] = 1/I[1]*(d[0]*A[0]*(M[3]*x[3]+0.5*M[4]*d[0]*x[1]/u[4]+M[5]*u[1])*u[3]-(I[0]-I[2])*x[0]*x[2])+K[0]*(u[6]-x[1]);
    dx[2] = 1/I[2]*(d[0]*A[0]*(M[6]*x[4]+M[7]*x[3]*x[4]+0.5*M[8]*d[0]*x[2]/u[4]+M[9]*u[0]+M[10]*u[2])*u[3]-(I[1]-I[0])*x[0]*x[1])+K[0]*(u[7]-x[2]);
    dx[3] = (-A[0]*u[3]*(F[2]*x[3]+F[3]*u[1]))/(m[0]*u[4])-x[0]*x[4]+x[1]+K[0]*(u[8]/u[4]-x[3])+C[0]*pow(x[4],2);
    dx[4] = (-A[0]*u[3]*(F[0]*x[4]+F[1]*u[2]))/(m[0]*u[4])-x[2]+x[0]*x[3]+K[0]*(u[9]/u[4]-x[4]);
}

/* Output equations. */
void compute_y(double *y, double *x, double *u, double **p)
{
    /* Retrieve model parameters. */
    double *F, *A, *m;
    F = p[0];   /* Aerodynamic force coefficient. */
    A = p[4];   /* Body reference area.        */
    m = p[6];   /* Mass.                  */
    
    /* y[0]: Angular velocity around x-axis. */
    /* y[1]: Angular velocity around y-axis. */
    /* y[2]: Angular velocity around z-axis. */
    /* y[3]: Acceleration in y-direction. */
    /* y[4]: Acceleration in z-direction. */
    y[0] = x[0];
    y[1] = x[1];
    y[2] = x[2];
    y[3] = -A[0]*u[3]*(F[0]*x[4]+F[1]*u[2])/m[0];
    y[4] = -A[0]*u[3]*(F[2]*x[3]+F[3]*u[1])/m[0];
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
    compute_dx(dx, x, u, p);
    
    /* Call function for output update. */
    compute_y(y, x, u, p);
    
    /* Clean up. */
    mxFree(p);
}
