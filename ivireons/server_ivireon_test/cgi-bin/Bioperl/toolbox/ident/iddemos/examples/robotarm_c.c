/*   Copyright 2005-2008 The MathWorks, Inc. */
/*   $Revision: 1.1.8.4 $ $Date: 2008/04/28 03:17:19 $ */
/*   Written by Peter Lindskog. */

/* Include libraries. */
#include "mex.h"
#include <math.h>

/* Specify the number of outputs here. */
#define NY 1

/* State equations. */
void compute_dx(double *dx, double *x, double *u, double **p)
{
    /* Declaration of model parameters and intermediate variables. */
    double *Fv, *Fc, *Fcs, *alpha, *beta, *J, *am, *ag, *kg1, *kg3, *dg, *ka, *da;
    double tauf, taus;   /* Intermediate variables. */
    
    /* Retrieve model parameters. */
    Fv    = p[0];    /* Viscous friction coefficient.            */
    Fc    = p[1];    /* Coulomb friction coefficient.            */
    Fcs   = p[2];    /* Striebeck friction coefficient.          */
    alpha = p[3];    /* Striebeck smoothness coefficient.        */
    beta  = p[4];    /* Friction smoothness coefficient.         */
    J     = p[5];    /* Total moment of inertia.                 */
    am    = p[6];    /* Motor moment of inertia scale factor.    */
    ag    = p[7];    /* Gear-box moment of inertia scale factor. */
    kg1   = p[8];    /* Gear-box stiffness parameter 1.          */
    kg3   = p[9];    /* Gear-box stiffness parameter 3.          */
    dg    = p[10];   /* Gear-box damping parameter.              */
    ka    = p[11];   /* Arm structure stiffness parameter.       */
    da    = p[12];   /* Arm structure damping parameter.         */
    
    /* Determine intermediate variables. */
    /* tauf: Gear friction torque. (sech(x) = 1/cosh(x)! */
    /* taus: Spring torque. */
    tauf = Fv[0]*x[2]+(Fc[0]+Fcs[0]/(cosh(alpha[0]*x[2])))*tanh(beta[0]*x[2]);
    taus = kg1[0]*x[0]+kg3[0]*pow(x[0],3);
    
    /* x[0]: Rotational velocity difference between the motor and the gear-box. */
    /* x[1]: Rotational velocity difference between the gear-box and the arm. */
    /* x[2]: Rotational velocity of the motor. */
    /* x[3]: Rotational velocity after the gear-box. */
    /* x[4]: Rotational velocity of the robot arm. */
    dx[0] = x[2]-x[3];
    dx[1] = x[3]-x[4];
    dx[2] = 1/(J[0]*am[0])*(-taus-dg[0]*(x[2]-x[3])-tauf+u[0]);
    dx[3] = 1/(J[0]*ag[0])*(taus+dg[0]*(x[2]-x[3])-ka[0]*x[1]-da[0]*(x[3]-x[4]));
    dx[4] = 1/(J[0]*(1.0-am[0]-ag[0]))*(ka[0]*x[1]+da[0]*(x[3]-x[4]));
}

/* Output equations. */
void compute_y(double *y, double *x)
{
    /* y[0]: Rotational velocity of the motor. */
    y[0] = x[2];
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
    compute_y(y, x);
    
    /* Clean up. */
    mxFree(p);
}
