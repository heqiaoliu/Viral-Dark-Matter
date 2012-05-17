/* ------------------------------------------------------------------------
 *  Program   :     eval_poly1d.c
 *  Author    :     Rajiv Singh
 *
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:17:38 $
 *
 *  Purpose   :     Evaluate poly1d nonlinearity
 * ------------------------------------------------------------------------*/


/* NOTE: DO NOT ASSIGN MEMORY ANYWHERE IN THIS CODE! */

#include "simstruc.h"
#include "eval_poly1d.h"

/* ---------------------------------------------------------------------
 * Purpose: Evaluate the nonlinearity for given parameters and regressors 
 * --------------------------------------------------------------------- */
void evaluate_poly1d
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
    
    int_T   i,j;
    real_T  temp;
    
    /* initialize output matrix with the constant coefficient of polynomial */
    for(i=0; i<NumRows; i++){
		y[i] = Par->Coefficients[Par->Degree]; 
    }
    
    /* add contribution of higher order terms */
    if (Par->Degree>0){
        for (i=0;i<NumRows;i++){
            temp = 1.0;
            for (j=0;j<Par->Degree;j++){
                temp *= X[i];
                y[i] += temp*Par->Coefficients[Par->Degree-1-j];
            } /* Par->Degree */
        } /* NumRows */
    }
}
