/*
 * Copyright 1984-2005 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $  $Date: 2009/11/16 22:31:31 $
 *
 * Instantiations of lexicographic comparison functions for each of the
 * nonsparse numeric classes and for char.
 *
 * compare_fcn.h contains the parameterized function body of the comparison
 * function.
 */

#include "lexicmp.h"

#define TYPE uint8_T
int lexi_compare_uint8
#include "compare_fcn.h"

#define TYPE uint16_T
int lexi_compare_uint16
#include "compare_fcn.h"

#define TYPE uint32_T
int lexi_compare_uint32
#include "compare_fcn.h"

#define TYPE int8_T
int lexi_compare_int8
#include "compare_fcn.h"

#define TYPE int16_T
int lexi_compare_int16
#include "compare_fcn.h"

#define TYPE int32_T
int lexi_compare_int32
#include "compare_fcn.h"

#define TYPE float
int lexi_compare_single
#include "compare_fcn.h"

#define TYPE double
int lexi_compare_double
#include "compare_fcn.h"


