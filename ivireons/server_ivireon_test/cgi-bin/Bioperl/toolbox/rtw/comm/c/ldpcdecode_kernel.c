/*
 *  LDPC decoder core for Communications Toolbox and Communications Blockset.
 *
 *  Copyright 2006-2008 The MathWorks, Inc.
 *  $Revision: 1.1.6.5 $ $Date: 2009/03/09 19:25:17 $
 */

#include <math.h>
#include <string.h>
#include "tmwtypes.h"
#include "ldpcdecode_kernel.h"

/*
 *    Reference:
 *    [1] William E. Ryan, "An introduction to LDPC codes," in Coding and Signal Processing for
 *        Magnetic Recoding Systems (Bane Vasic, ed.), CRC Press, 2004.
 *        http://www.ece.arizona.edu/%7Eryan/New%20Folder/ryan-crc-ldpc-chap.pdf
 *
 *        Equations (36.10), (36.12) and (36.13) correspond to equations (4.9), (4.11) and (4.12) in
 *        the on-line version respectively.
 */

/*********************************************************************************************************
 * Fast_tanh() computes tanh(L(q_{i'j})/2) in equation (36.10).
 *********************************************************************************************************/

void Fast_tanh(real_T *dest, real_T *src, int32_T num)
{
    int32_T counter;

    for(counter = 0; counter < num; counter++, dest++, src++)
        *dest = tanh(*src/2);
}

/*********************************************************************************************************
 * UpdateCheckNodes() computes L(r_{ji}) in equation (36.10).
 *********************************************************************************************************/

void UpdateCheckNodes(real_T *Lr, real_T *Product_tanh_Lq, real_T *tanh_Lq, const int32_T *chtable, int32_T num_edge)
{
    int32_T counter;
    real_T temp;

    for(counter = 0; counter < num_edge; counter++, Lr++, tanh_Lq++)
    {
        temp = (Product_tanh_Lq[chtable[counter]] / *tanh_Lq);
        if(temp == 1)
            *Lr = 2 * 19.07;  /* 19.07 is the smallest x (up to 2 decimal places) s.t. tanh(x) == 1. */
        else
        {
            if(temp == -1)
                *Lr = -2 * 19.07;
            else
                *Lr = log((1+temp)/(1-temp));
        }
    }
}

/*********************************************************************************************************
 * UpdateVariableNodes() computes L(q_{ij}) in equation (36.12) and L(Q_{i}) in equation (36.13).
 *********************************************************************************************************/

void UpdateVariableNodes(real_T *Lq, real_T *LQ, const real_T *Lc, real_T *Lr, const int32_T *DegList, int32_T NumSubmatrices)
{
    real_T *ptr;
    int32_T counter1, counter2, SubmatrixCounter, num_node, deg_node;

    for(SubmatrixCounter = 0; SubmatrixCounter < NumSubmatrices; SubmatrixCounter++)
    {
        num_node = *DegList++;
        deg_node = *DegList++;

        for(counter1 = 0; counter1 < num_node; counter1++, LQ++, Lc++)
        {
            ptr = Lr;

            /* Equation (36.13) */
            *LQ = 0;
            for(counter2 = 0; counter2 < deg_node; counter2++, Lr++)
                *LQ += *Lr;

            *LQ += *Lc;

            /* Equation (36.12) */
            for(counter2 = 0; counter2 < deg_node; counter2++, Lq++, ptr++)
                *Lq = *LQ - *ptr;
        }
    }
}

int32_T ParityCheck(real_T *LQ, int32_T BlockLength, int32_T NumCheckEqns, int32_T NumSubmatrices,
                    const int32_T *DegList, const int32_T *RowIndicesList,
                    real_T *FinalParityCheck, real_T *HardDecision)
{
    int32_T ind, num_node, deg_node, counter1, counter2, result;
    real_T *HardDecisionPtr;

    /* Perform hard-decisions */

    HardDecisionPtr = HardDecision;
    for(ind = 0; ind < BlockLength; ind++, LQ++, HardDecisionPtr++)
        if(*LQ <= 0)
            *HardDecisionPtr = 1;
        else
            *HardDecisionPtr = 0;

    /* Clear final parity-checks */
    memset(FinalParityCheck, 0, NumCheckEqns * sizeof(real_T));

    /* Compute parity-checks */

    HardDecisionPtr = HardDecision;
    for(ind = 0; ind < NumSubmatrices; ind++)
    {
        num_node = *DegList++;
        deg_node = *DegList++;

        for(counter1 = 0; counter1 < num_node; counter1++)
        {
            if(*HardDecisionPtr)
                for(counter2 = 0; counter2 < deg_node; counter2++, RowIndicesList++)
                    FinalParityCheck[*RowIndicesList] = 1 - FinalParityCheck[*RowIndicesList];
            else
                RowIndicesList += deg_node; /* Skip the whole column since decoded bit = 0 */

            HardDecisionPtr++;
        }
    }

    result = 0;
    for(ind = 0; ind < NumCheckEqns; ind++, FinalParityCheck++)
        if(*FinalParityCheck)
        {
            result = 1;
            break;
        }

    return(result); /* result = 0 if all parity-checks are satisfied */
}

/*********************************************************************************************************
 * LDPCDecode_Core() implements the main loop of the message-passing algorithm.
 *********************************************************************************************************/

SPC_DECL void LDPCDecodeKernel(int32_T NumIterations, int32_T BlockLength, int32_T NumCheckEqns,            /* input */
                      int32_T TotalNumEdges, int32_T NumSubmatrices,                               /* input */
                      const int32_T *DegList, const int32_T *RowIndicesList,                       /* input */
                      int8_T EachIterCheck, int8_T DoFinalCheck, const real_T *Lc,                 /* input */
                      real_T *Lq,                                                       /* input and output */
                      real_T *LQ, real_T *FinalParityCheck, real_T *FinalNumIterations,           /* output */
                      real_T *Product_tanh_Lq, real_T *Lr, int32_T *zeroloc)           /* temporary buffers */
{
    int32_T num, counter;
    const int32_T *checknodeptr;
    real_T *Lq_local;

    int32_T NumOfRowsWithZeroTanh, TempValueInZeroloc;
    int8_T ChangedZeroloc; /* equal to 1 if zeroloc has some nonzero values */

    /* Assume that zeroloc points to an array of NumCheckEqns zeros */
    /* zeroloc is used to handle the situation where tanh(L(q_{ij}/2)) = 0 */

    /********************** Main loop *********************/

    *FinalNumIterations = 0;

    for(num = 0; num < NumIterations; num++)
    {
        /* Initialize Product_tanh_Lq */
        for(counter = 0; counter < NumCheckEqns; counter++)
            Product_tanh_Lq[counter] = 1;

        /* In-place computation of tanh(L(q_{ij}/2)) */
        Fast_tanh(Lq, Lq, TotalNumEdges);

        /* Lq now holds tanh(L(q_{ij}/2)) */

        /* Compute the product of tanh over all elements in V_j in equation (36.10) */
        Lq_local = Lq;
        checknodeptr = RowIndicesList;

        NumOfRowsWithZeroTanh = 0;
        ChangedZeroloc = 0;

        for(counter = 0; counter < TotalNumEdges; counter++, checknodeptr++, Lq_local++)
        {
            if(*Lq_local != 0)
                Product_tanh_Lq[*checknodeptr] *= *Lq_local;
            else
            {
                /*
                 * Unfortunately, tanh(L(q_{ij}/2)) = 0.
                 * It is an extremely rare event, but we still need to take care of this possibility.
                 *
                 * We must make sure that division by zero will not occur inside UpdateCheckNodes().
                 * Moreover, we need to compute Lr correctly before calling UpdateVariableNodes().
                 *
                 * tanh(L(q_{ij}/2)) is stored in *Lq_local.
                 * j is stored in *checknodeptr. i is a function of counter.
                 *
                 * Strategy:
                 *
                 * Let j be fixed.
                 * If tanh(L(q_{ij}/2)) = 0 for exactly one i (say i0), then L(r_{ji}) = 0 for all i != i0,
                 * and for i = i0, UpdateCheckNodes() will compute L(r_{ji}) correctly
                 * if tanh(L(q_{ij}/2)) is changed to any nonzero value between -1 and 1.
                 *
                 * If tanh(L(q_{ij}/2)) = 0 for two or more i's, then L(r_{ji}) = 0 for all i.
                 */

                /* First, change tanh(L(q_{ij}/2)) to a nonzero value so that division
                 * by zero will not occur inside UpdateCheckNodes(). */
                *Lq_local = 1;

                /* Check if this is the first zero for this particular j (i.e. *checknodeptr) */
                if(zeroloc[*checknodeptr] == 0)
                {
                    /*
                     * Yes, this is the first zero for this j (i.e. *checknodeptr).
                     * For now, assume that there are no more zeros, and store counter (which specifies i0),
                     * so that we may set L(r_{ji}) = 0 for all i != i0.
                     */

                    zeroloc[*checknodeptr] = counter + 1; /* Add 1 to make it greater than 0 */

                    /* Keep track of the number of rows (i.e. j) we need to fix before calling UpdateVariableNodes().
                     * For each j, NumOfRowsWithZeroTanh may be increased once only,
                     * because zeroloc[*checknodeptr] is no longer equal to 0. */
                    NumOfRowsWithZeroTanh++;

                    ChangedZeroloc = 1; /* Do this to make sure that zeroloc will be cleared for next iteration. */

                    /* Since we have set *Lq_local = 1, we don't need to do */
                    /* Product_tanh_Lq[*checknodeptr] *= *Lq_local;         */
                }
                else
                    if(zeroloc[*checknodeptr] > 0)
                    {
                        /*
                         * This is the second zero for this j (i.e. *checknodeptr).
                         * This is actually good news, since we may simply
                         * set Product_tanh_Lq[*checknodeptr] = 0 to force all L(r_{ji}) to 0 for all i.
                         */
                        Product_tanh_Lq[*checknodeptr] = 0;

                        /* Since Product_tanh_Lq[*checknodeptr] is forced to 0, UpdateCheckNodes()
                         * will set L(r_{ji}) = 0 for all i. All subsequent zeros (if any) will be taken care of. */

                        /* Set zeroloc[*checknodeptr] = -1 to record the fact that there are two zeros already. */
                        zeroloc[*checknodeptr] = -1;

                        /* Keep track of the number of rows (i.e. j) we need to fix before calling UpdateVariableNodes().
                         * For each j, NumOfRowsWithZeroTanh may be decreased once only,
                         * because zeroloc[*checknodeptr] is now negative. */
                        NumOfRowsWithZeroTanh--;
                    }
            }
        }

        /* Equation (36.10) */
        UpdateCheckNodes(Lr, Product_tanh_Lq, Lq, RowIndicesList, TotalNumEdges);

        if(NumOfRowsWithZeroTanh > 0)
        {
            /* Repair rows with tanh(L(q_{ij}/2)) = 0 for exactly one i. */

            Lq_local = Lr;    /* Reuse Lq_local to process Lr. */
            checknodeptr = RowIndicesList;

            for(counter = 0; counter < TotalNumEdges; counter++, checknodeptr++, Lq_local++)
            {
                if((TempValueInZeroloc = zeroloc[*checknodeptr]) > 0)
                    if(TempValueInZeroloc != (counter + 1))
                        *Lq_local = 0;  /* Clear Lr if it is not the location where tanh(L(q_{ij}/2)) = 0 */
            }
        }

        if(ChangedZeroloc)
            memset(zeroloc, 0, NumCheckEqns * sizeof(int32_T));

        /* Equations (36.12) and (36.13) */
        UpdateVariableNodes(Lq, LQ, Lc, Lr, DegList, NumSubmatrices);

        *FinalNumIterations += 1;

        /* Do parity-check if necessary, using Lr as a temporary buffer for hard-decisions */
        /* It is always big enough because the total number of edges is always greater than the block length */

        if(EachIterCheck)
            if(!ParityCheck(LQ, BlockLength, NumCheckEqns, NumSubmatrices, DegList, RowIndicesList, FinalParityCheck, Lr))
                break;
    }

    /****************** End of main loop ******************/

    if(!EachIterCheck && DoFinalCheck)
        ParityCheck(LQ, BlockLength, NumCheckEqns, NumSubmatrices, DegList, RowIndicesList, FinalParityCheck, Lr);
}

/* [EOF] */
