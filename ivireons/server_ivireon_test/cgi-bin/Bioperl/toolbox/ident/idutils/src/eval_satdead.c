/* ------------------------------------------------------------------------
 *  Program   :     eval_satdead.c
 *  Author    :     Rajiv Singh
 *
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.8.2 $ $Date: 2007/12/14 14:46:37 $
 *
 *  Purpose   :     Evaluate Saturation, Dead Zone nonlinearities.
 * ------------------------------------------------------------------------*/


/* NOTE: DO NOT ASSIGN MEMORY ANYWHERE IN THIS CODE! */

#include <math.h>
#include "simstruc.h"
#include "eval_satdead.h"

/* ---------------------------------------------------------------------
 * Purpose: Evaluate the nonlinearity for given parameters and regressors 
 * --------------------------------------------------------------------- */
void evaluate_satdead
(
    real_T       *y, 
    const real_T *X, 
    uint_T       NumRows, 
    ParStruc     *Par
)
{
    /* y: output
     * X: regressor matrix 
     * Par: parameters required for simulation
     * NumRows: number of time samples (=number of rows of X) (=1 for S function)
     */
    
	int_T   i;
    real_T temp1, temp2;
    
    /* initialize output matrix */
    for(i=0; i<NumRows; i++){
		y[i] = 0.0; 
    }
    
    if (Par->NumInterval==0){
        /* empty interval => two sides */
        for(i=0; i<NumRows; i++){
            if (Par->IsSaturation==1){
                /* Saturation */
                
                temp1 = Par->Center-fabs(Par->Scale);
                temp2 = Par->Center+fabs(Par->Scale);
                
                temp1 = MAX(temp1, X[i]);
                y[i]  = MIN(temp1, temp2);
                                
                /*
                y[i] = MIN(
                            MAX(Par->Center-fabs(Par->Scale), X[i]),
                            Par->Center+fabs(Par->Scale)
                          );
                */
            }else{
                /* Deadzone */
                
                temp1 = X[i]-Par->Center+fabs(Par->Scale);
                temp2 = X[i]-Par->Center-fabs(Par->Scale);
                y[i] = MIN(temp1,0.0) + MAX(0.0, temp2);
                /*
                y[i] = MIN(X[i]-Par->Center+fabs(Par->Scale), 0) +
                       MAX(0, X[i]-Par->Center-fabs(Par->Scale));
                 */
            }
        }
    }else{
        /* single sided or degenerate */
        for(i=0; i<NumRows; i++){
            if (Par->IsSaturation==1){
                /* Saturation */
                
                temp1 = MAX(Par->Interval[0], X[i]);
                y[i]  = MIN(temp1, Par->Interval[1]);
                /* 
                 y[i] = MIN( MAX(Par->Interval[0], X[i]), Par->Interval[1] );
                 */
                
            }else{
                /* Deadzone */
                
                y[i] = MIN(X[i]-Par->Interval[0], 0.0) + 
                       MAX(0.0, X[i]-Par->Interval[1]);
            }
        }
    }    
}
