/* ------------------------------------------------------------------------
 *  Program   :     eval_linear.c
 *  Author    :     Rajiv Singh
 *
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:17:36 $
 *
 *  Purpose   :     Evaluate Linear nonlinearity.
 * ------------------------------------------------------------------------*/

#include "simstruc.h"
#include "eval_linear.h"

/* ---------------------------------------------------------------------
 * Purpose: Evaluate the nonlinearity for given parameters and regressors 
 * --------------------------------------------------------------------- */
void evaluate_linear
(
    real_T *Y, 
    const real_T *X, 
    uint_T NumRows, 
    uint_T DimInp,
    ParStruc *Par 
)
{
    /* Y: output
     * X: regressor matrix 
     * Par: parameters requires for simulation
     * DimInp:  number of regressors (number of columns of X)
     * NumRows: number of time samples (=number of rows of X) (=1 for S function)
     */ 
 
    /* NOTE: DO NOT ASSIGN MEMORY ANYWHERE IN THIS CODE! */
    
	uint_T i, k;	
    real_T tempY;
    
    for (i=0; i<NumRows; i++){
        tempY = 0;
        for (k=0; k<DimInp; k++){
            tempY += X[i+k*NumRows]*Par->LinearCoef[k]; 
        }
        Y[i] = tempY + Par->OutputOffset;
    }
}
