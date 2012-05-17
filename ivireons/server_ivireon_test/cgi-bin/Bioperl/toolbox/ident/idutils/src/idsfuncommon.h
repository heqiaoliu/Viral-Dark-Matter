/* ------------------------------------------------------------------------
 *  Program   :     idsfuncommon.h
 *  Author    :     Rajiv Singh
 *
 *  Copyright 2007 The MathWorks, Inc.
 *  $Revision: 1.1.8.1 $    $Date: 2007/11/09 20:17:51 $
 *
 *  Purpose   :     Common definitions shared by various S functions
 * -----------------------------------------------------------------------*/

#ifndef __IDSFUNCOMMON_H__
#define __IDSFUNCOMMON_H__

#include <stdlib.h>    /* for malloc, free */
#include <math.h>
#include "simstruc.h"

enum { Ts_Idx, NumReg_Idx }; 

/* Sampling Interval */
#define TS(S)   ssGetSFcnParam(S, Ts_Idx)

/* Number of Regressors (input dimension) */
#define NUMREG(S) ssGetSFcnParam(S, NumReg_Idx)

#endif
