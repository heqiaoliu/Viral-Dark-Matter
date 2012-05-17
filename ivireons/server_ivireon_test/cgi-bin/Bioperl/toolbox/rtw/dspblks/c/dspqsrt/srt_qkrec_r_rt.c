/* QSRT_R_RT Function to sort an input array of real singles for Sort block in Signal Processing Blockset.
 *
 * Implement Quicksort algorithm using indices (qid)
 * Note: this algorithm is different from MATLAB's sorting
 * for complex values with same magnitude.
 *
 * Sorts an array of singles based on the "Quicksort" algorithm,
 * using an index vector rather than the data itself.
 *
 *  Copyright 1995-2005 The MathWorks, Inc.
 *  $Revision: 1.2.2.4 $  $Date: 2005/12/22 18:33:58 $
 */

#if (!defined(INTEGER_CODE) || !INTEGER_CODE)

#include "dspsrt_rt.h"

/* The recursive quicksort routine: */
EXPORT_FCN void MWDSP_SrtQkRecR(const real32_T *qid_array, int_T *qid_index,
                        int_T i, int_T j )
{
    int_T pivot;
    if (MWDSP_SrtQidFindPivotR(qid_array, qid_index, i, j, &pivot)) {
        int_T k = MWDSP_SrtQidPartitionR(qid_array, qid_index, i, j, pivot);
        MWDSP_SrtQkRecR(qid_array, qid_index, i, k-1);
        MWDSP_SrtQkRecR(qid_array, qid_index, k, j);
    }
}

#endif /* !INTEGER_CODE */


/* [EOF] srt_qkrec_r_rt.c */
