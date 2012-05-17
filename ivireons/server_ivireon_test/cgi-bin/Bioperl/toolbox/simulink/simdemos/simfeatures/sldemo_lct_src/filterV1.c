/* Copyright 2005-2006 The MathWorks, Inc. */

/* $Revision: 1.1.6.2 $ */

#include "your_types.h"
#include "myfilter.h"

/* IIR First Order Filter */
FLT  filterV1(const FLT signal, const FLT prevSignal, const FLT gain)
{
  FLT filtOut;
  FLT a1,b0;
  
  /* Limit gain */
  if (gain > 1)
      a1 = 1;
  else if (gain < 0)
      a1 = 0;
  else
      a1 = gain;
  
  /* Calculate filter const */
  b0 = 1-a1;

  /* Calculate difference equation */
  filtOut = b0*signal + a1*prevSignal;
  
  /* Return Result */
  return filtOut;
}
