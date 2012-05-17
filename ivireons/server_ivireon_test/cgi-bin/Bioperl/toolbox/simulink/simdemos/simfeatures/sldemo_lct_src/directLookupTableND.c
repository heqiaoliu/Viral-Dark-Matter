/* Copyright 2006-2008 The MathWorks, Inc. */

/* $Revision: 1.1.6.2 $ */

#include "lookupTable.h"

#ifndef CLIP_INDEX
#define CLIP_INDEX(idx,ll,ul)                   \
          ( ((idx ) >= (ul)) ? (ul) :           \
            (((idx) <= (ll)) ? (ll) : (idx)) )
#endif

FLT directLookupTableND(const FLT *tableND, const UINT32 nbDims, const UINT32 *tableDims, const UINT32 *tableIdx)
{
  UINT32 i;
  UINT32 offset = 0;
  UINT32 cumprodDim = 1;
  
  /* The ND table elements are stored in column-major format */
  for (i = 0; i < nbDims; i++) {
      offset += cumprodDim * CLIP_INDEX(tableIdx[i], 0, tableDims[i]-1);      
      cumprodDim *= tableDims[i];
  }

  return (tableND[offset]);
}
