/* ------------------------------------------------------------------------
 *  Program   :     eval_treepartition.c
 *  Author    :     Rajiv Singh
 *
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.8.2 $ $Date: 2007/12/14 14:46:39 $
 *
 *  Purpose   :     Evaluate Tree Partition nonlinearity.
 * ------------------------------------------------------------------------*/

#include "idsfuncommon.h"
#include "eval_treepartition.h"

/* ---------------------------------------------------------------------
 * Purpose: CV2M ?
 * --------------------------------------------------------------------- */
void cv2m(real_T *a, real_T *ttm, uint_T k, uint_T DimInp, uint_T mnot)
{
    uint_T  i, j, ii = 0;
    for (i = 0; i<DimInp; i++){
        for (j = 0; j<=i; j++){
            ttm[i+DimInp*j] = a[k+ii*mnot];
            ttm[j+DimInp*i] = a[k+ii*mnot];
            ii++;
        }
    }
}/* cv2m */

/* ---------------------------------------------------------------------
 * Purpose: LMD ?
 * --------------------------------------------------------------------- */
real_T lmd(real_T *a, real_T *b, real_T *ttm, uint_T k, uint_T DimInp, uint_T mnot )
{
	uint_T i,j;
	real_T y = 0.0;	
	
	cv2m(a,ttm,k,DimInp,mnot);
	for (i = 0; i<DimInp; i++){
		for (j = 0; j<DimInp; j++){
			y += ttm[i+DimInp*j]*b[i]*b[j];
		}
	}
	return y;
} /* lmd */

/* ---------------------------------------------------------------------
 * Purpose: SCPR ?
 * --------------------------------------------------------------------- */
real_T scpr(real_T *a, real_T *b, uint_T k, uint_T mnot, uint_T DimInp) 
{
	uint_T i;
	real_T y = 0.0;	

	for (i=0; i<DimInp; i++){
        y += a[k+mnot*i]*b[i];
    }
	return y;
} /* scpr */

/* ---------------------------------------------------------------------
 * Purpose: ADEV ?
 * --------------------------------------------------------------------- */
real_T adev(real_T *tt, real_T *ttm, real_T *lfmax, real_T *lfmin, 
            real_T dl0, ParStruc *Par, uint_T DimInp, 
            uint_T MaxLvl)
{
	int_T j, i;
    TreeStruc *Tree = Par->Tree;
	int_T ntpntr = 0;
    uint_T mnot = Par->NumberOfUnits;
    
	real_T ldelta, y, clvl;

	for (j=0; j<MaxLvl; j++){
		ldelta = dl0/Par->Threshold*sqrt(Par->NoiseVariance*lmd(Tree->LocalCovMatrix, tt, ttm, ntpntr, DimInp, mnot));
		lfmax[j] = scpr(Tree->LocalParVector,tt,ntpntr, mnot, DimInp) + ldelta;
		lfmin[j] = lfmax[j] - 2.0*ldelta;
        
        clvl = 0.0;
		for (i = 0; i<DimInp; i++){
            clvl += Tree->LocalizingVectors[ntpntr+i*mnot]*Tree->LocalizingVectors[ntpntr+i*mnot];
        }
		
        if ((clvl==0.0) & (j<MaxLvl-1)){
			for (i=j+1; i<MaxLvl; i++){
                lfmax[i] = lfmax[j]; 
                lfmin[i] = lfmin[j];
			}
			break;
		} else {
			clvl = 0.0;
			for (i=1; i< DimInp; i++){
				clvl += Tree->LocalizingVectors[ntpntr+i*mnot]*tt[i];
			}
			if (clvl<Tree->LocalizingVectors[ntpntr]){
                ntpntr = (int_T) Tree->AncestorDescendantPntr[ntpntr+mnot]-1;
            }
			else {
                ntpntr = (int_T) Tree->AncestorDescendantPntr[ntpntr+2*mnot]-1;
            }
		}
	}
    
	for (i=MaxLvl-2; i>=0; i--)
	{
	   	lfmax[i] = MIN(lfmax[i+1],lfmax[i]);
	   	lfmin[i] = MAX(lfmin[i+1],lfmin[i]);
	}
    
	j=0;
	for (i=0; i<MaxLvl-1; i++){
        j += lfmax[i]<lfmin[i];
    }
	
    y = (lfmax[j]+lfmin[j])/2.0;
	
    return y;
} /* ade */

/* ---------------------------------------------------------------------
 * Purpose: Evaluate the nonlinearity for given parameters and regressors 
 * --------------------------------------------------------------------- */
void evaluate_treepartition
(
    real_T *Y, 
    const real_T *X, 
    uint_T NumRows, 
    uint_T DimInp, 
    ParStruc *Par
)
{
    /* Y: output
     * X: regressor matrix (X)
     * Par: parameters of tree partition required for simulation
     * Par->IsLinear: true if nonlinearity is absent (empty Par)
     * DimInp:  number of regressors (number of columns of X) + 1
     * Par->(ttv,ttm,lfmax,lfmin): temp arrays required for computation
     * NumRows: number of time samples (=number of rows of X) (=1 for S function)
     */ 
 
    /* NOTE: DO NOT ASSIGN MEMORY ANYWHERE IN THIS CODE! */
    
    boolean_T IsLinear = Par->IsLinear;
    uint_T i, k;  
    real_T tempY, dl0 = sqrt(2*log(Par->SampleLength));
	real_T *ttv, *ttm, *lfmax, *lfmin; 
    TreeStruc *Tree = Par->Tree;
    uint_T MaxLvl = 0;

    if(IsLinear){
		for (i=0; i<NumRows; i++){
            tempY = 0;
            for (k=1; k < DimInp; k++){
                tempY += (X[i+(k-1)*NumRows]- Par->RegressorMean[k-1]) 
                          * Par->LinearCoef[k-1];  /* *(*(X+i)+k-1) */
            }
            Y[i] = tempY + Par->OutputOffset;;
        }
        return;
    }
    
    /* full computation if the nonlinearity is indeed present */
	ttv     = Par->ttv;
	ttm     = Par->ttm;
	lfmax   = Par->lfmax;
	lfmin   = Par->lfmin;
    
	MaxLvl = (uint_T) Tree->TreeLevelPntr[Par->NumberOfUnits-1];
    for (i=0; i<NumRows; i++){
        ttv[0] = 1;
		tempY = 0.0;
        for (k=1; k<DimInp; k++){
            ttv[k] =  X[i+(k-1)*NumRows] - Par->RegressorMean[k-1]; /* *(*(X+i)+k-1); */
        }
        tempY = adev(ttv, ttm, lfmax,lfmin, dl0, Par, DimInp, MaxLvl);
        tempY += Par->OutputOffset;
        Y[i] = tempY;
    }
}
