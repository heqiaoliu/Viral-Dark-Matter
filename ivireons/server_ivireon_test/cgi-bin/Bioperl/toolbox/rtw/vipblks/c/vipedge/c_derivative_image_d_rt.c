/*
 *  C_DERIVATIVE_IMAGE_D_RT Helper function for Edge block (Canny method).
 *
 *  Copyright 1995-2005 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:07:50 $
 */
#include "vipedge_rt.h"  

EXPORT_FCN void MWVIP_C_Derivative_Image_D(const real_T *input,
                              const real_T *dgauss1D,
                                    real_T *filteredDataC,
                                    int_T inpRows,
                                    int_T inpCols,
                                    int_T halfFiltLen)
{   /* Compute the first derivative of the image in column direction */
    /* Seperable Convolution */ 
    int_T r,c,k, C1, C2;
    real_T sum;

    for (r=0; r<inpRows; r++)
    {
      for (c=0; c<inpCols; c++)
      {
        sum = 0; 
        for (k=1; k<halfFiltLen; k++)
        {
          C1 = (c+k)%inpCols; C2 = (c-k+inpCols)%inpCols;
          sum += dgauss1D[k]*(-input[C1*inpRows+r] + input[C2*inpRows+r]);
        }
        filteredDataC[c*inpRows+r] = sum; 
      }
    }
}

/* [EOF] c_derivative_image_d_rt.c */

