/* Copyright 2005-2008 The MathWorks, Inc. */

/* $Revision: 1.1.6.2 $ */

/* This file is an example legacy lookup table source file */
/* The object of this example is to interface to the lookup functions below */

#include "your_types.h"
#include "lookupTable.h"

/* 1D Lookup Tables */
/* The table algorithms implement a kinda close lookup method for simplicity sake */

FLT lookupTable1D(const FLT *InputMap, const FLT *OutputMap, const UINT32 MapLength, FLT InputValue)
{
  int idx = 0;
  FLT result;

  /* Search for the Element in the InputMap Above the Input Value*/
  while ( (idx < (MapLength-1)) && (InputMap[idx] < InputValue) )
    idx++;
  
  result = OutputMap[idx];
  return result;
}
