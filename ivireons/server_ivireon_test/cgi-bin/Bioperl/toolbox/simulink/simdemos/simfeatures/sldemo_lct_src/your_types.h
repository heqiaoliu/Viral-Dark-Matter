/* Copyright 2005-2008 The MathWorks, Inc. */

/* $Revision: 1.1.6.2 $ */

#ifndef _YOUR_TYPES_H_
#define _YOUR_TYPES_H_

#include <limits.h>

typedef float        FLT;
typedef double       DBL;
typedef int          INT;
typedef unsigned int UINT;

#if UINT_MAX  >= 0xFFFFFFFFL
/* 32 bit (or more) processors */
typedef  unsigned int UINT32;
#else
/* 32 bit (or less) processors */
typedef  unsigned long UINT32;
#endif

#endif   /* _YOUR_TYPES_H_ */
