/*
 *  R_DERIVATIVE_IMAGE_D_RT Helper function for Edge block (Canny method).
 *
 *  Copyright 1995-2005 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:07:58 $
 */
#include "vipedge_rt.h"  

EXPORT_FCN void MWVIP_R_Derivative_Image_D(const real_T *input,
                              const real_T *dgauss1D,
                              real_T *filteredDataR,
                              int_T inpRows,
                              int_T inpCols,
                              int_T halfFiltLen)
{   /* Compute the first derivative of the image in row direction */
    /* Seperable Convolution */
    int_T r,c,k, R1, R2;
    real_T sum;

    for (r=0; r<inpRows; r++)
    {
      for (c=0; c<inpCols; c++)
      {
        sum = 0; 
        for (k=1; k<halfFiltLen; k++)
        {
          R1 = (r+k)%inpRows; R2 = (r-k+inpRows)%inpRows;
          sum += dgauss1D[k]*(-input[c*inpRows+R1] + input[c*inpRows+R2]);
        }
        filteredDataR[c*inpRows+r] = sum;
      }
    }
}

/* [EOF] r_derivative_image_d_rt.c */

