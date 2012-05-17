/*
 *  VIP_DRAWSHAPES_SIM.CPP - simulation helper functions for VIP Draw Shapes block. 
 *
 *  Copyright 1995-2008 The MathWorks, Inc.
 *  $Revision: 1.1.6.1 $  $Date: 2009/11/16 22:31:34 $
 */

#include "vipprojective_rt.h"  
/*
 * tiebreak_fcn
 * Used by the comparison functions in compare_fcn.c to break ties
 * between two equal rows.  Break the tie using the index value
 * to preserve a stable sort.
 */
static int tiebreak_fcn(const void *ptr1, const void *ptr2)
{
    const sort_item *item1 = (const sort_item *) ptr1;
    const sort_item *item2 = (const sort_item *) ptr2;
    
    if (item1->index == item2->index) {
        return S1_S2_ARE_EQUAL;
    } else {
        return(item1->index > item2->index ? S1_IS_GREATER : S2_IS_GREATER);
    }
}

/*
 * select_compare_function
 * Select the comparison function to pass to qsort according to
 * the class of the input matrix.
 *
 * Input
 * -----
 * in      - input matrix (mxArray)
 *
 * Returns function pointer
 */
static compare_function select_compare_function(int_T dtype, int_T *bytesPerElement)
{
    compare_function result;

    switch (dtype)
    {
    case 3:
        result = lexi_compare_uint8;
        *bytesPerElement = sizeof(uint8_T);
        break;

    case 5:
        result = lexi_compare_uint16;
        *bytesPerElement = sizeof(uint16_T);
        break;

    case 7:
        result = lexi_compare_uint32;
        *bytesPerElement = sizeof(uint32_T);
        break;

    case 2:
        result = lexi_compare_int8;
        *bytesPerElement = sizeof(int8_T);
        break;

    case 4:
        result = lexi_compare_int16;
        *bytesPerElement = sizeof(int16_T);
        break;

    case 6:
        result = lexi_compare_int32;
        *bytesPerElement = sizeof(int32_T);
        break;

    case 1:
        result = lexi_compare_single;
        *bytesPerElement = sizeof(real32_T);
        break;

    case 0:
        result = lexi_compare_double;
        *bytesPerElement = sizeof(real_T);
        break;
    default:
        /* This should never happen */
        result = NULL;
        *bytesPerElement = 0;
        break;
    }

    return(result);
}

/*
 * make_sort_item_array
 * Allocates and initializes an array of sort_item structs.  Caller is 
 * responsible for freeing the allocated array.
 *
 * Inputs
 * ------
 * in       - mxArray; must be a 2-D numeric or char matrix.
 *
 * Returns allocated sort_item array.
 */
static void make_sort_item_array(void *in,
                          int_T num_rows, 
                          int_T num_cols,
                          int_T elem_size,
                          sort_item *result)
{
    uint8_T *byte_ptr;
    int stride;
    int length;
    int k;

    byte_ptr = (uint8_T *)in;

    /*
     * stride is the linear offset between adjacent matrix
     * elements on the same row.
     */
    stride = num_rows;

    /*
     * length is the number of matrix elements on each row.
     */
    length = num_cols;

    for (k = 0; k < num_rows; k++)
    {
        /* 
         * The k-th item in the array has to have a pointer
         * to the k-th row in the input matrix.  This is 
         * accomplished via a little arithmetic on byte pointers.
         */
		if (byte_ptr != NULL)
		{
            result[k].data = (void *)(byte_ptr + k*elem_size);
		}
		else
		{
			result[k].data = NULL;
		}
        
        result[k].stride = stride;
        result[k].length = length;
        result[k].index  = k;       
        result[k].tiebreak_fcn = tiebreak_fcn;
        result[k].user_data = NULL;   /* unused by sortrowsmex */
    }
}

EXPORT_FCN void MWVIP_SortRows(void *allEdges, int_T numRows, 
                               int_T inputDType, sort_item *sortItemArray)
{
    int_T bytesPerInputElement;
    compare_function cmp_function; 
    cmp_function    = select_compare_function(inputDType,&bytesPerInputElement);
    make_sort_item_array(allEdges, numRows, 3, bytesPerInputElement, sortItemArray);
    qsort(sortItemArray, numRows, sizeof(sort_item), cmp_function);
}


/* [EOF] vip_drawshapes_sim.cpp */

