/*    
 *  File: tbd.c
 *  Abstract: The file defines function for performing the Traceback 
 *            Decodng function of the Viterbi algorithm. 
 *            Used by MLSE equalizer, TCM decoder blocks.
 *            An example of inlining using the function wrapper method.
 *            Refer to the sfunction files for comments.
 *
 *  Copyright 2005-2006 The MathWorks, Inc.
 *  $Revision: 1.1.6.3 $ $Date: 2009/03/09 19:25:27 $
 */

#include "tbd.h"
 
/* Traceback decoding */
SPC_DECL int32_T TBDecode(int32_T *pTbPtr, uint32_T minState, const int32_T tbLen, 
                 uint32_T *pTbInput, uint32_T *pTbState, 
                 const uint32_T numStates)
{
    int32_T i, input  = 0;
    int32_T tbwork = pTbPtr[0];
   
    /* Starting at the minimum metric state at the current
     * time in the traceback array:
     *     - determine the input leading to that state
     *     - follow the most likely path back to the previous
     *       state by updating the value of minState
     *     - adjust the traceback index value mod tbLen
     * Repeat this tbLen+1 (for current level) times to complete
     * the traceback
     */        
    for(i = 0; i < tbLen+1; i++) 
    {                                
        input    = (int32_T) pTbInput[minState+(tbwork*numStates)];
        minState = pTbState[minState+(tbwork*numStates)];
        tbwork   = (tbwork > 0) ? tbwork-1 : tbLen ;
    }
     
    /* Increment the traceback index and store */
    pTbPtr[0] = (pTbPtr[0] < tbLen) ? pTbPtr[0]+1 : 0;

    return input;    
}

/* EOF */
