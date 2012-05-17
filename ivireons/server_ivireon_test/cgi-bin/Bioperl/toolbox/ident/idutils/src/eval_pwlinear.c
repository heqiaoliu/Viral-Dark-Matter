/* ------------------------------------------------------------------------
 *  Program   :     eval_pwlinear.c
 *  Author    :     Rajiv Singh
 *
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:17:40 $
 *
 *  Purpose   :     Evaluate pwlinear nonlinearity
 * ------------------------------------------------------------------------*/


/* NOTE: DO NOT ASSIGN MEMORY ANYWHERE IN THIS CODE! */

#include "idsfuncommon.h"
#include "eval_pwlinear.h"

/* -------------------------------------------------------------------
 * Purpose: Calculate the contribution of nonlinearity, which is sum 
 * of triangular units 
 * -------------------------------------------------------------------
 */
void addPwlinearNLResp
(
    real_T  *y,
    const real_T  *X, 
    real_T  *T,
    real_T  *Coef,
    uint_T  NumRows, 
    uint_T  NumUnits
)
{
  /* 
   * Xnl: input variable, NumRows-by-DimXnl matrix
   * D: dilation parameters, DimXnl-by-NumUnits vector
   * T: translation parameters, 1-by-NumUnits matrix
   * Coef: output coefficients (NumUnits-by-1 vector)
   * [NumRows,DimXnl]  = size(Xnl)
   * NumUnits = number of basis function terms (NumberOfUnits property)
   * y: output vector (NumRows-by-1)
   */
  
   int_T i, j; 
   
   for(j=0; j<NumRows; j++){
       for(i=0; i<NumUnits; i++){               
           /* basis fcn |x| */  
           y[j] += (fabs(X[j]+T[i])) * Coef[i];
        }
   }
}

/* ---------------------------------------------------------------------
 * Purpose: Evaluate the nonlinearity for given parameters and regressors 
 * --------------------------------------------------------------------- */
void evaluate_pwlinear
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
     * NOTE: DimInp = number of regressors, is always 1.
     */
    
	int_T   i;
    
    /* initialize output matrix */
    for(i=0; i<NumRows; i++){
		y[i] = 0.0; 
    }
    
    /* add linear component of response */
    if (Par->DimXlin==1){
        for(i=0; i<NumRows; i++){
            y[i] += X[i]*Par->LinearCoef[0] + Par->OutputOffset;
        }
    }
    
    if ( Par->NumberOfUnits>0 ){
        /* add contribution of nonlinearity */
        addPwlinearNLResp(y, X, Par->Translation, Par->OutputCoef,
                       NumRows, Par->NumberOfUnits);       
    } /* if */
    
} /* evaluate_pwlinear */
