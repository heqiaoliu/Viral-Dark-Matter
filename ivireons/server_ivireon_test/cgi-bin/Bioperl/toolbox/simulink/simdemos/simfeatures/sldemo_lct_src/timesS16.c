/* Copyright 2005-2006 The MathWorks, Inc. */

/* $Revision: 1.1.6.1 $ */

#include "timesFixpt.h"

myFixpt timesS16(const myFixpt in1, const myFixpt in2, const uint8_T fracLength)
{
    return ((myFixpt)(in1*in2 >> fracLength));
}
