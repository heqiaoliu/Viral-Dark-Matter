#
#====================================================================
# gmake makefile fragment for building MEX functions using Borland C
# Copyright 2007-2010 The MathWorks, Inc.
#====================================================================
#
SHELL = cmd
OBJEXT = obj
CC = $(COMPILER)
LD = ilink32
.SUFFIXES: .$(OBJEXT)

OBJLIST += $(SRC_FILES:.c=.$(OBJEXT))

target: $(TARGET)

BORDIR = $(subst /,\,$(BORLAND))
ML_INCLUDES = -I"$(MATLAB_ROOT)\extern\include"
ML_INCLUDES+= -I"$(MATLAB_ROOT)\simulink\include"
ML_INCLUDES+= -I"$(MATLAB_ROOT)\toolbox\shared\simtargets"
SYS_INCLUDE = $(ML_INCLUDES)

# Additional includes
|>START_EXPAND_INCLUDES<|
SYS_INCLUDE += -I|>EXPAND_DIR_NAME<||>END_EXPAND_INCLUDES<|

EML_LIBS = libemlrt.lib libut.lib libmwmathutil.lib
MEX_LIBS = libmx.lib libmex.lib libmat.lib
BCC_LIBS = c0d32.obj import32.lib cw32mt.lib

SYS_LIBS += $(MEX_LIBS) $(BCC_LIBS) $(EML_LIBS)
DEFFILE = "$(MATLAB_ROOT)\extern\lib\$(MATLAB_ARCH)\borland\mexFunction.def"

LINKFLAGS = -aa -c -Tpd -x -Gn
LINKFLAGS += -L"$(BORDIR)\lib" -L"$(BORDIR)\lib\32bit"
LINKFLAGS += -L"$(MATLAB_ROOT)\extern\lib\$(MATLAB_ARCH)\borland"

COMP_FLAGS = $(COMPFLAGS) -DMX_COMPAT_32
LINK_FLAGS = $(LINKFLAGS)
ifeq ($(EMC_CONFIG),optim)
  COMP_FLAGS += $(OPTIMFLAGS)
  LINK_FLAGS += $(LINKOPTIMFLAGS)
else
  COMP_FLAGS += $(DEBUGFLAGS)
  LINK_FLAGS += $(LINKDEBUGFLAGS)
endif
LINK_FLAGS += |>ADDITIONAL_LDFLAGS<|

CFLAGS = |>OPTS<| $(COMP_FLAGS) $(USER_INCLUDE) $(SYS_INCLUDE)

%.$(OBJEXT) : %.c
	$(CC) $(CFLAGS) "$<"

# Additional sources

|>START_EXPAND_RULES<|%.$(OBJEXT) : |>EXPAND_DIR_NAME<|/%.c
	$(CC) $(CFLAGS) "$<"

|>END_EXPAND_RULES<|

$(TARGET): $(OBJLIST) $(MAKEFILE)
	$(LD) $(LINK_FLAGS) $(OBJLIST),$(TARGET),,$(SYS_LIBS),$(DEFFILE),

#====================================================================

