/* Copyright 2007 The MathWorks, Inc. */

/* 
 * File: can_io_driver.h
 *
 */

#ifndef __CAN_IO_DRIVER__
    #define __CAN_IO_DRIVER__

    #include "rtwtypes.h"

    uint32_T txMessage(uint8_T *);
    uint32_T rxMessage(uint8_T *); 
    void initIO(void);
#endif
