/*   Copyright 2005-2008 The MathWorks, Inc. */
/*   $Revision: 1.1.8.3 $ $Date: 2008/04/28 03:17:23 $ */
/*   Written by Peter Lindskog. */

/* Include libraries. */
#include "mex.h"
#include <math.h>

/* Specify the number of outputs here. */
#define NY 3

/* State equations. */
void compute_dx(double *dx, double *x, double *u, double **p)
{
    /* Retrieve model parameters. */
    double *m, *a, *b, *Cx, *Cy, *CA;
    m  = p[0];   /* Vehicle mass.                    */
    a  = p[1];   /* Distance from front axle to COG. */
    b  = p[2];   /* Distance from rear axle to COG.  */
    Cx = p[3];   /* Longitudinal tire stiffness.     */
    Cy = p[4];   /* Lateral tire stiffness.          */
    CA = p[5];   /* Air resistance coefficient.      */
    
    /* x[0]: Longitudinal vehicle velocity. */
    /* x[1]: Lateral vehicle velocity. */
    /* x[2]: Yaw rate. */
    dx[0] = x[1]*x[2]+1/m[0]*(Cx[0]*(u[0]+u[1])*cos(u[4])-2*Cy[0]*(u[4]-(x[1]+a[0]*x[2])/x[0])*sin(u[4])+Cx[0]*(u[2]+u[3])-CA[0]*pow(x[0],2));
    dx[1] = -x[0]*x[2]+1/m[0]*(Cx[0]*(u[0]+u[1])*sin(u[4])+2*Cy[0]*(u[4]-(x[1]+a[0]*x[2])/x[0])*cos(u[4])+2*Cy[0]*(b[0]*x[2]-x[1])/x[0]);
    dx[2] = 1/(pow(((a[0]+b[0])/2),2)*m[0])*(a[0]*(Cx[0]*(u[0]+u[1])*sin(u[4])+2*Cy[0]*(u[4]-(x[1]+a[0]*x[2])/x[0])*cos(u[4]))-2*b[0]*Cy[0]*(b[0]*x[2]-x[1])/x[0]);
}

/* Output equations. */
void compute_y(double *y, double *x, double *u, double **p)
{
    /* Retrieve model parameters. */
    double *m, *a, *b, *Cx, *Cy;
    m  = p[0];   /* Vehicle mass.                    */
    a  = p[1];   /* Distance from front axle to COG. */
    b  = p[2];   /* Distance from rear axle to COG.  */
    Cx = p[3];   /* Longitudinal tire stiffness.     */
    Cy = p[4];   /* Lateral tire stiffness.          */
    
    /* y[0]: Longitudinal vehicle velocity. */
    /* y[1]: Lateral vehicle acceleration. */
    /* y[2]: Yaw rate. */
    y[0] = x[0];
    y[1] = 1/m[0]*(Cx[0]*(u[0]+u[1])*sin(u[4])+2*Cy[0]*(u[4]-(x[1]+a[0]*x[2])/x[0])*cos(u[4])+2*Cy[0]*(b[0]*x[2]-x[1])/x[0]);
    y[2] = x[2];
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
    double *x, *u, **p, *dx, *y;
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
