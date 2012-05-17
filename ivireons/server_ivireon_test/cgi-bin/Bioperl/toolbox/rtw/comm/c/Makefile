#
# Makefile for comm_rt module
#
# Copyright 2008 The MathWorks, Inc.
# $Revision: 1.1.6.1 $ $Date: 2009/03/09 19:25:05 $
#

include $(BUILD_HARNESS)/makerules/sandbox_root.mk

TOP_DSPBLKS_DIR := $(SANDBOX_ROOT)/toolbox/dspblks

NO_MAKEHEADER_WHATSOEVER := 1
MODNAME := comm_rt

DEFSRCINC += -I./include -I$(TOP_DSPBLKS_DIR)/include -I$(SANDBOX_ROOT)/simulink/include
CPPFLAGS += -DSPC_EXPORTS -DDSPBLKS_SIM_SFCN 

include $(MAKE_INCLUDE_DIR)/Makefile.module
