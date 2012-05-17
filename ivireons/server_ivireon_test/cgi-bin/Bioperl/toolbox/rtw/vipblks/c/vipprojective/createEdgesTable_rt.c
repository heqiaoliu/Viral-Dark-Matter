/*
 *  createEdgesTable_rt  helper function for Projective
 *  transformation/Draw shapes block.
 *	Creates edges table. 
 *  Copyright 1995-2006 The MathWorks, Inc.
 *  $Revision: 1.1.8.3 $  $Date: 2009/11/16 22:31:32 $
 */
#include "vipprojective_rt.h"   

EXPORT_FCN void MWVIP_CreateEdgesTable(int32_T *outPts,int_T numVertices,
                      int32_T *allEdges, int32_T *globalEdges,
                      sort_item *sortItemArray, int32_T *offset,
                      boolean_T drawAntiAliased)
{
#define  ISFLTPT 1
#include "mwvip_create_edges_table_tplt.c"
#undef ISFLTPT
} 

EXPORT_FCN void MWVIP_CreateEdgesTable_Int(int32_T *outPts,int_T numVertices,
                      int32_T *allEdges, int32_T *globalEdges,
                      sort_item *sortItemArray, int32_T *offset,
                      boolean_T drawAntiAliased)
{
#define  ISFLTPT 0
#include "mwvip_create_edges_table_tplt.c"
#undef ISFLTPT
} 


/* [EOF] createEdgesTable_rt.c */
