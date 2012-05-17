/* Copyright 2005-2008 The MathWorks, Inc. */

/* $Revision: 1.1.6.2 $ */

#ifndef _LOOK_UP_TABLE_H_
#define _LOOK_UP_TABLE_H_

#include "your_types.h"

/* 1D Lookup Table */
extern FLT lookupTable1D(const FLT *InputMap, const FLT *OutputMap, const UINT32 MapLength, FLT InputValue);

/* ND direct Lookup Table */
extern FLT directLookupTableND(const FLT *tableND, const UINT32 nbDims, const UINT32 *tableDims, const UINT32 *tableIdx);

#define DirectLookupTable3D(tableND,tableDims,tableIdx) \
                          directLookupTableND(tableND,3,tableDims,tableIdx)

#define DirectLookupTable4D(tableND,tableDims,tableIdx) \
                          directLookupTableND(tableND,4,tableDims,tableIdx)

#endif /* _LOOK_UP_TABLE_H_ */ 
