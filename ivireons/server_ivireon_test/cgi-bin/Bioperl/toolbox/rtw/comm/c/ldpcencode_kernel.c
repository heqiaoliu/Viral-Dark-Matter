/*
 *  LDPC encoder core for Communications Toolbox and Communications Blockset.
 *
 *  Copyright 2006-2008 The MathWorks, Inc.
 *  $Revision: 1.1.6.6 $ $Date: 2009/03/09 19:25:18 $
 */

#include <math.h>
#include <string.h>
#include "tmwtypes.h"
#include "ldpcencode_kernel.h"

/*
 * GF2MatrixMul computes the modulo-2 matrix product of a vector (specified by source) and
 * a matrix (specified by RowIndices, rowloc and ColumnSum), or solves a system of linear equations by
 * forward/backward substitution (if source == dest).
 *
 * RowIndices specifies the row indices of the nonzero elements in the matrix.
 * ColumnSum specifies the number of nonzero elements in each column.
 * rowloc specifies the offset (in RowIndices) of the first nonzero element in each column.
 *
 * E.g. for this matrix
 *      [ 1     0     0
 *        0     1     0
 *        1     1     1 ]
 *
 *   RowIndices = [0 2 1 2 2]
 *   rowloc     = [0 2 4]
 *   ColumnSum  = [2 2 1]
 */
void GF2MatrixMul(int8_T *source, int8_T *dest, int32_T srclen, const int32_T *RowIndices,
                  const int32_T *rowloc, const int32_T *ColumnSum, int8_T direction)
{
    int32_T columnindex, columncounter, rowcounter, rowindex;

    if(direction == 1)   /* direction = 1 or -1 */
        columnindex = 0; /* Start from the first column for forward substitution */
    else
        columnindex = srclen - 1; /* Start from the last column for backward substitution */

    /* columnindex has been properly initialized */
    for(columncounter = 0; columncounter < srclen; columncounter++, columnindex += direction)
    {
        if(source[columnindex] != 0)
            for(rowcounter = 0; rowcounter < ColumnSum[columnindex]; rowcounter++)
            {
                rowindex = RowIndices[rowloc[columnindex] + rowcounter];
                dest[rowindex] = 1 - dest[rowindex];
            }
    }
}

SPC_DECL void LDPCEncodeKernel(int8_T *InformationBits, int8_T *ParityCheckBits,
                      int32_T NumInfoBits, int32_T NumParityCheckBits, int8_T EncodingMethod,
                      const int32_T *A_RowIndices, const int32_T *A_RowStartLoc, const int32_T *A_ColumnSum,
                      const int32_T *B_RowIndices, const int32_T *B_RowStartLoc, const int32_T *B_ColumnSum,
                      const int32_T *L_RowIndices, const int32_T *L_RowStartLoc, const int32_T *L_ColumnSum,
                      const int32_T *RowOrder, int8_T *ReorderBuffer)
{
    int32_T counter;
    int8_T *MatrixProductBuffer;

    /* EncodingMethod = 1, 0, or -1 */

    if(*RowOrder >= 0)
    {
        /* RowOrder[0] >= 0 only if the last (N-K) columns of H are not triangular, or if they are
         * lower/upper triangular along the anti-diagonal and has a full anti-diagonal, e.g.,
         *
         * [ 0 0 1             [ 1 0 1
         *   0 1 0        or     1 1 0      or    a non-triangular matrix
         *   1 1 1 ]             1 0 0 ]
         */

        MatrixProductBuffer = ReorderBuffer;     /* Will need to have an extra re-ordering step. */
    }
    else
    {
        /* RowOrder[0] < 0 only if the last (N-K) columns of H are lower/upper triangular and has
         * a full diagonal, e.g.,
         *
         * [ 1 0 0             [ 1 1 1
         *   1 1 0        or     0 1 0
         *   0 1 1 ]             0 0 1 ]
         */
        MatrixProductBuffer = ParityCheckBits;   /* No need to have an extra re-ordering step. */
    }

    /* Clear the buffer for computing the next matrix product */
    memset(MatrixProductBuffer, 0, NumParityCheckBits * sizeof(int8_T));

    /* Compute the matrix product between first K columns of H and the information bits */
    GF2MatrixMul(InformationBits, MatrixProductBuffer, NumInfoBits, A_RowIndices, A_RowStartLoc, A_ColumnSum, 1);

    /* Need to perform this substitution if the last (N-K) columns of H are not triangular */
    if(EncodingMethod == 0)
    {
        /* Forward substitution for the lower triangular matrix obtained from factorization in GF(2) */
        GF2MatrixMul(MatrixProductBuffer, MatrixProductBuffer, NumParityCheckBits, L_RowIndices, L_RowStartLoc, L_ColumnSum, 1);

        /* Make sure that backward substitution will be used in the common step */
        EncodingMethod = -1;
    }

    if(*RowOrder >= 0)
        /* In this case, MatrixProductBuffer = ReorderBuffer */
        /* Do an extra re-ordering step               */
        for(counter = 0; counter < NumParityCheckBits; counter++)
            ParityCheckBits[counter] = MatrixProductBuffer[RowOrder[counter]];

    /* Solve for the parity-check bits */

    /* Common step: If object property EncodingAlgorithm is 'Matrix Inverse', do backward substitution;
       otherwise, do forward or backward substitution according to EncodingAlgorithm */
    GF2MatrixMul(ParityCheckBits, ParityCheckBits, NumParityCheckBits, B_RowIndices, B_RowStartLoc, B_ColumnSum, EncodingMethod);
}

/* [EOF] */
