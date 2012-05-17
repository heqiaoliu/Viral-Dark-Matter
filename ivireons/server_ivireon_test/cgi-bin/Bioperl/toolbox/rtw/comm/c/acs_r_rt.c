/*    
 *    File: acs_r_rt.c
 *    Abstract: The file defines function for performing the Add-Compare
 *              -Select function of the Viterbi algorithm. 
 *              Used by MLSE equalizer, TCM, Viterbi decoder blocks.
 *              An example of inlining using the function wrapper method.
 *              Refer to the sfunction files for comments.
 *
 *    Copyright 2005-2006 The MathWorks, Inc.
 *    $Revision: 1.1.6.2 $ $Date: 2006/06/23 19:39:17 $
 */

#include "acs_r_rt.h"

/* Add-Compare-Select for Single precision */
int_T ACS_R(const int_T     numStates,
                  real32_T *pTempMet, 
            const int_T     alpha,    
                  real32_T *pBMet,    
                  real32_T *pStateMet,
                  uint32_T *pTbState,
                  uint32_T *pTbInput,
                  int32_T  *pTbPtr, 
            const uint32_T *pNxtSt, 
            const uint32_T *pEncOut,
            const real32_T *maxValue) 
{
    int_T    minstate = 0;
    real32_T renorm   = maxValue[0];
    int_T    stateIdx;

    for(stateIdx = 0; stateIdx < numStates; stateIdx++) {
        pTempMet[stateIdx] = renorm;
    }

    for(stateIdx = 0; stateIdx < numStates; stateIdx++) 
    {
        const real32_T currmetric = pStateMet[stateIdx];

        int_T inpIdx;
        for(inpIdx = 0; inpIdx < alpha; inpIdx++) 
        {
            const int_T    offsetIdx             = inpIdx*numStates + stateIdx;
            const int_T    nextStateIdx          = (int_T)pNxtSt[offsetIdx];
            const real32_T currMetPlusBranchMet = currmetric + pBMet[(int_T)pEncOut[offsetIdx]];

            if(currMetPlusBranchMet < pTempMet[nextStateIdx]) {
                const int_T tmpIdx = (numStates * pTbPtr[0]) + nextStateIdx;
                pTbState[tmpIdx]       = (uint32_T)stateIdx;
                pTbInput[tmpIdx]       = (uint32_T)inpIdx;
                pTempMet[nextStateIdx] = currMetPlusBranchMet;
                if(pTempMet[nextStateIdx] < renorm) {
                    renorm = pTempMet[nextStateIdx];
                }
            }
        }
    }

    for(stateIdx = 0; stateIdx < numStates; stateIdx++) {
        const real32_T tmpVal = pTempMet[stateIdx] - renorm;
        pStateMet[stateIdx] = tmpVal;
        if(tmpVal == 0.0F) {
            minstate = stateIdx;
        }
    }
    
    return minstate;
}                 
/* end ACS_R() */

/* EOF */
