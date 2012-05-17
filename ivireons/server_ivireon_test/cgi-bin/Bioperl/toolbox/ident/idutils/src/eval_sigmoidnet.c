/* ------------------------------------------------------------------------
 *  Program   :     eval_sigmoidnet.c
 *  Author    :     Rajiv Singh
 *
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:17:44 $
 *
 *  Purpose   :     Evaluate sigmoidnet nonlinearity
 * ------------------------------------------------------------------------*/


/* NOTE: DO NOT ASSIGN MEMORY ANYWHERE IN THIS CODE! */

#include "idsfuncommon.h"
#include "eval_sigmoidnet.h"

/* -------------------------------------------------------------------
 * Purpose: Calculate the contribution of nonlinearity, which is sum 
 * of sigmoid units: \sum_i(1/(1+exp(-x_i))*a_i) 
 * -------------------------------------------------------------------
 */
void addSigmoidNLResp
(
    real_T  *y,
    real_T  *Xnl, 
    real_T  *D, 
    real_T  *T,
    real_T  *Coef,
    uint_T  NumRows, 
    uint_T  DimXnl,
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
  
   int_T i, j, k; 
   real_T temp; 
   
   for(j=0; j<NumRows; j++){
       for(i=0; i<NumUnits; i++){    
           temp = 0.0;
           for (k=0; k<DimXnl; k++){
               temp += Xnl[k*NumRows+j]*D[i*DimXnl+k];
           }
           temp += T[i];
           /* basis fcn 1/(1+exp(-x)) */
           y[j] += (1/(1+exp(-temp))) * Coef[i];
        }
   }
}

/* ---------------------------------------------------------------------
 * Purpose: Evaluate the nonlinearity for given parameters and regressors 
 * --------------------------------------------------------------------- */
void evaluate_sigmoidnet
(
    real_T       *y, 
    const real_T *X, 
    uint_T       NumRows, 
    uint_T       DimInp, 
    ParStruc     *Par
)
{
    /* y: output
     * X: regressor matrix 
     * Par: parameters required for simulation
     * DimInp:  number of regressors (number of columns of X)
     * NumRows: number of time samples (=number of rows of X) (=1 for S function)
     */
    
	int_T   i, j, k;
    real_T  *Xnl        = Par->Xnl; /* preallocated memory */
    real_T  temp1       = 0.0;
    real_T  temp2       = 0.0;
    
    /* initialize output matrix */
    for(i=0; i<NumRows; i++){
		y[i] = 0.0; 
    }
    
    /* add linear component of response */
    for(i=0; i<NumRows; i++){
        temp2 = 0.0;
        for(j=0; j<Par->DimXlin; j++){
            temp1 = 0.0;
            for(k=0; k<DimInp; k++){
                temp1 += (X[k*NumRows+i]-Par->RegressorMean[k])
                         *Par->LinearSubspace[j*DimInp+k];
            }
            temp2 += temp1*Par->LinearCoef[j];
        }
        y[i] += temp2 + Par->OutputOffset;
    }
    
    if ( (Par->NumberOfUnits>0) && (Par->DimXnl>0) ){
        /* compute nonlinear regressors */
        for(i=0; i<NumRows; i++){
            for(j=0; j<Par->DimXnl; j++){
                temp1 = 0.0;
                for(k=0; k<DimInp; k++){
                    temp1 += (X[k*NumRows+i]-Par->RegressorMean[k])
                    *Par->NonLinearSubspace[j*DimInp+k];
                }
                Xnl[j*NumRows+i] = temp1;
            }
        }
        
        /* add contribution of nonlinearity */
        addSigmoidNLResp(y, Xnl, Par->Dilation, Par->Translation, Par->OutputCoef,
                       NumRows, Par->DimXnl, Par->NumberOfUnits);       
    } /* if */
    
} /* evaluate_sigmoidnet */
