/*
 *  File: tbd.h
 * 
 *  Header file for the Traceback Decoding function of the Viterbi Algorithm.
 *  Used by scommlseeq.cpp and scomtcmdec.cpp.
 *
 *  Copyright 2005-2006 The MathWorks, Inc.
 *  $Revision: 1.1.6.3 $ $Date: 2009/03/09 19:25:47 $
 */

#ifndef __TBD_H__
#define __TBD_H__

#include <string.h>
#include "tmwtypes.h"
#include "spc_decl.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Traceback decoding */
SPC_DECL int32_T TBDecode(int32_T *pTbPtr, uint32_T minState, const int32_T tbLen, 
                 uint32_T *pTbInput, uint32_T *pTbState, 
                 const uint32_T numStates);

#ifdef __cplusplus
} // end of extern "C" scope
#endif

#endif  /* __TBD_H__ */

/* EOF */
