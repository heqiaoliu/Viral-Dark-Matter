/* ------------------------------------------------------------------------
 *  Program   :     eval_wavenet.c
 *  Author    :     Rajiv Singh
 *
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:17:48 $
 *
 *  Purpose   :     Evaluate Wavenet nonlinearity.
 * ------------------------------------------------------------------------*/


/* NOTE: DO NOT ASSIGN MEMORY ANYWHERE IN THIS CODE! */

#include "idsfuncommon.h"
#include "eval_wavenet.h"

/* -------------------------------------------------------------------
 * Purpose: Calculate the basis (scaling or wavelet) function values 
 * -------------------------------------------------------------------
 */
void addWavenetNlResp
(
    real_T  *y, 
    int_T	Fnb,
    real_T  *Xnl, 
    real_T  *D, 
    real_T  *T,
    real_T  *Coef,
    uint_T  NumRows, 
    uint_T  DimXnl,
    uint_T  Nbbf
)
{
  /* 
   * Fnb: function selector Fnb=1 for scaling, Fnb=2 for wavelet
   * Xnl: input variable, NumRows-by-DimXnl matrix
   * D: dilation parameters, Nbbf-by-1 vector
   * T: translation parameters, Nbbf-by-DimXnl matrix
   * Coef: scaling or wavelet coefficient (Nbbf-by-1 vector)
   * [NumRows,DimXnl]  = size(Xnl)
   * Nbbf = number of basis function terms in scaling (Fnb=1) or wavelet 
   *        term (Fnb=2); sum(Nnbf_Fnb) for Fnb=(1,2) = NumUnits
   * y: output vector (NumRows-by-1)
   */
  
   int_T i, j, k; 
   real_T temp, temp2; 
   
   /* ssPrintf("y(start)=%g\n",y[0]); */
   for(j=0; j<NumRows; j++){
       for(i=0; i<Nbbf; i++){    
           temp = 0.0;
           for (k=0; k<DimXnl; k++){
               temp2 = Xnl[k*NumRows+j]-T[k*Nbbf+i];
               temp += temp2*temp2;
           }
           temp = (D[i]*D[i])*temp;
           
           if (Fnb==1){
               /* scaling fcn phi(|x|) = exp(-|x|/2) */
               y[j] += exp(-0.5*temp)*Coef[i];
           }else{
               /* wavelet fcn psi(|x|) = (DimXnl-|x|)*exp(-|x|/2) */
               y[j] += (DimXnl-temp)*exp(-0.5*temp)*Coef[i];
           }
        }
   }
}

/* ---------------------------------------------------------------------
 * Purpose: Evaluate the nonlinearity for given parameters and regressors 
 * --------------------------------------------------------------------- */
void evaluate_wavenet
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
    
    /* add contribution of scaling functions */
    if (Par->NumScale>0){
        addWavenetNlResp(y, 1, Xnl, Par->ScalingDilation, 
                      Par->ScalingTranslation, Par->ScalingCoef,
                      NumRows, Par->DimXnl, Par->NumScale);
    }
    
    /* add contribution of wavelet functions */
    if (Par->NumWavelet>0){
        addWavenetNlResp(y, 2, Xnl, Par->WaveletDilation, 
                      Par->WaveletTranslation, Par->WaveletCoef,
                      NumRows, Par->DimXnl, Par->NumWavelet);
    }
    
}
