/*
 *  Header file for LDPC decoder kernel,
 *  used by Communications Toolbox and Communications Blockset.
 *
 *  Copyright 2006 The MathWorks, Inc.
 *  $Revision: 1.1.6.4 $ $Date: 2009/03/09 19:25:38 $
 */

#ifndef __LDPCDECODE_KERNEL_H__
#define __LDPCDECODE_KERNEL_H__

#include "tmwtypes.h"
#include "spc_decl.h"

#ifdef __cplusplus
extern "C" {
#endif

SPC_DECL void LDPCDecodeKernel(      int32_T NumIterations,       /* input */
                            int32_T BlockLength,         /* input */
                            int32_T NumCheckEqns,        /* input */
                            int32_T TotalNumEdges,       /* input */
                            int32_T NumSubmatrices,      /* input */
                      const int32_T *DegList,            /* input */
                      const int32_T *RowIndicesList,     /* input */
                            int8_T  EachIterCheck,       /* input */
                            int8_T  DoFinalCheck,        /* input */
                      const real_T  *Lc,                 /* input */
                            real_T  *Lq,                 /* input and output */
                            real_T  *LQ,                 /* output */
                            real_T  *FinalParityCheck,   /* output */
                            real_T  *FinalNumIterations, /* output */
                            real_T  *Product_tanh_Lq,    /* temporary buffers */
                            real_T  *Lr,                 /* temporary buffers */
                            int32_T *zeroloc);           /* temporary buffers */

#ifdef __cplusplus
} // end of extern "C" scope
#endif

#endif /* __LDPCDECODE_KERNEL_H__ */

/* [EOF] */
