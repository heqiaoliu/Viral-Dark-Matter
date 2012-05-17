/* Copyright 2005-2006 The MathWorks, Inc. */

/* $Revision: 1.1.6.1 $ */

#ifndef _MYFILTER_H_
#define _MYFILTER_H_

#include "your_types.h"

extern FLT  filterV1(const FLT signal, const FLT prevSignal, const FLT gain);
extern FLT  filterV2(const FLT* signal, const FLT prevSignal, const FLT gain);

#endif /* _MYFILTER_H_ */
