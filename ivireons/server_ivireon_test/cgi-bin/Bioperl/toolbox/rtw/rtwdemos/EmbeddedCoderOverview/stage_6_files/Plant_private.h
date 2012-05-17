/* Copyright 2007 The MathWorks, Inc. */
/*
 * File: Plant_private.h
 *
 * Real-Time Workshop code generated for Simulink model Plant.
 *
 * Model version                        : 1.51
 * Real-Time Workshop file version      : 6.6  (R2007a Prerelease)  10-Dec-2006
 * Real-Time Workshop file generated on : Fri Dec 15 11:48:47 2006
 * TLC version                          : 6.6 (Dec 10 2006)
 * C source code generated on           : Fri Dec 15 11:48:47 2006
 */
#ifndef _RTW_HEADER_Plant_private_h_
#define _RTW_HEADER_Plant_private_h_
#include "rtwtypes.h"
#ifndef __RTWTYPES_H__
#error This file requires rtwtypes.h to be included
#else
#ifdef TMWTYPES_PREVIOUSLY_INCLUDED
#error This file requires rtwtypes.h to be included before tmwtypes.h
#else

/* Check for inclusion of an incorrect version of rtwtypes.h */
#ifndef RTWTYPES_ID_C08S16I32L32N32F1
#error This code was generated with a different "rtwtypes.h" than the file included
#endif                                 /* RTWTYPES_ID_C08S16I32L32N32F1 */
#endif                                 /* TMWTYPES_PREVIOUSLY_INCLUDED */
#endif                                 /* __RTWTYPES_H__ */

/* Imported (extern) block signals */
extern real_T PlantInput;              /* '<Root>/V_cmd' */
void Trigger_Init(void);
void Plant(void);

#endif                                 /* _RTW_HEADER_Plant_private_h_ */

/* File trailer for Real-Time Workshop generated code.
 *
 * [EOF]
 */
