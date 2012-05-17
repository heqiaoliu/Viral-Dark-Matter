/* Copyright 2007 The MathWorks, Inc. */
#include "SimpleTable.h"

double SimpleTable(double xIn, double xAxis[], double yAxis[], int axisLength)
{
    /* This routine assumes monotonically increasing values of X */
    double outValue;
    int axisLoc;
    axisLoc = (int) (axisLength * 0.5);  /* Start at mid point of table */
    
    if (xIn >= xAxis[axisLength - 1])
    {
        outValue = yAxis[axisLength - 1];
    }
    else if (xIn <=  xAxis[0])
    {
        outValue = yAxis    [0];
    }
    else
    {
        /* Find the closest point to the current xIn */
        if ((xIn <= xAxis[axisLoc + 1]) && (xIn >= xAxis[axisLoc]))
        {
            /* Current axis location is correct */
        }
        else if (xAxis[axisLoc] > xIn)
        {
            /* Search Down */
            while ((axisLoc > 0) && 
                    !((xIn <= xAxis[axisLoc + 1]) && (xIn >= xAxis[axisLoc])))
            {
                axisLoc--;
            }
        }    
        else
        {
            /* Search up */
            while ((axisLoc < axisLength -1) && 
                   !((xIn <= xAxis[axisLoc + 1]) && (xIn >= xAxis[axisLoc])))
            {
                axisLoc++;
            }
        }
        /* out = y1 + dx * (y2 - y1)/(x2-x1) */
        outValue = yAxis[axisLoc] + (xIn - xAxis[axisLoc]) *
                                    ((yAxis[axisLoc+1] - yAxis[axisLoc])/
                                     (xAxis[axisLoc+1] - xAxis[axisLoc]));
        
    } /* ends else value */
        
    return(outValue);
}

