/*
 *  ARETHREEPOINTSCOLLINEAR_RT  helper function for Projective
 *  transformation block.
 *	Determines if three or more points of a quadrilateral are 
 *  collinear or not. 
 *  Copyright 1995-2005 The MathWorks, Inc.
 *  $Revision: 1.1.8.2 $  $Date: 2006/12/27 21:26:03 $
 */
#include "vipprojective_rt.h"  

EXPORT_FCN boolean_T MWVIP_Are3PtsCollinear(int32_T *pts) 
{
    /* return if three or more points are collinear */
    int_T i;
    boolean_T isInvalid = false;
    int_T dR_AB  = pts[0] - pts[2];
    int_T dC_AB  = pts[1] - pts[3];
    for (i = 1; i <= 3; i++) {
        int_T ptBRow = pts[2*i];
        int_T ptBCol = pts[2*i+1];
        int_T ptCRow,ptCCol, dR_BC, dC_BC;
        if (i == 3) ptCRow = pts[0];
        else ptCRow = pts[2*i+2];
        if (i == 3) ptCCol = pts[1];
        else ptCCol = pts[2*i+3];
        dR_BC  = ptBRow - ptCRow; 
        dC_BC  = ptBCol - ptCCol; 
        if (dR_AB*dC_BC  == dC_AB*dR_BC) {
            /* Points A, B and C are collinear. */
            isInvalid = true;
            break;
        }
        dR_AB  = dR_BC;
        dC_AB  = dC_BC;
    }
    return isInvalid;
}

/* [EOF] are3PtsCollinear_rt.c */
