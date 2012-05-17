#
#====================================================================
# gmake makefile fragment for building MEX functions using LCC
# Copyright 2007-2010 The MathWorks, Inc.
#====================================================================
#
SHELL = cmd
OBJEXT = obj
CC = $(COMPILER)
LD = $(LINKER)
.SUFFIXES: .$(OBJEXT)

OBJLIST += $(SRC_FILES:.c=.$(OBJEXT))
MEXSTUB = $(MEX_FILE_NAME_WO_EXT)2.$(OBJEXT)
LCCSTUB = $(MEX_FILE_NAME_WO_EXT)_lccstub.$(OBJEXT)

target: $(TARGET)

ML_INCLUDES = -I"$(subst \,\\,$(MATLAB_ROOT)\extern\include)"
ML_INCLUDES+= -I"$(subst \,\\,$(MATLAB_ROOT)\simulink\include)"
ML_INCLUDES+= -I"$(subst \,\\,$(MATLAB_ROOT)\toolbox\shared\simtargets)"
SYS_INCLUDE = $(ML_INCLUDES)

# Additional includes
|>START_EXPAND_INCLUDES<|
SYS_INCLUDE += -I"$(subst \,\\,|>EXPAND_DIR_NAME<|)"|>END_EXPAND_INCLUDES<|

EML_LIBS = libemlrt.lib libut.lib libmwblascompat32.lib libmwmathutil.lib
SYS_LIBS += $(EML_LIBS)

DIRECTIVES = $(MEX_FILE_NAME_WO_EXT)_mex.def

COMP_FLAGS = $(subst \,\\,$(COMPFLAGS)) -DMX_COMPAT_32
LINK_FLAGS0= $(subst \,\\,$(subst $(MEXSTUB),$(LCCSTUB),$(LINKFLAGS)))
LINK_FLAGS = $(filter-out "%mexFunction.def", $(LINK_FLAGS0))

ifeq ($(EMC_CONFIG),optim)
  COMP_FLAGS += $(OPTIMFLAGS)
  LINK_FLAGS += $(LINKOPTIMFLAGS)
else
  COMP_FLAGS += $(DEBUGFLAGS)
  LINK_FLAGS += $(LINKDEBUGFLAGS)
endif
LINK_FLAGS += -o $(TARGET)
LINK_FLAGS += |>ADDITIONAL_LDFLAGS<|

CFLAGS = |>OPTS<| $(COMP_FLAGS) $(USER_INCLUDE) $(SYS_INCLUDE)

%.$(OBJEXT) : %.c
	$(CC) $(CFLAGS) "$<"

# Additional sources

|>START_EXPAND_RULES<|%.$(OBJEXT) : |>EXPAND_DIR_NAME<|/%.c
	$(CC) -Fo"$@" $(CFLAGS) "$<"

|>END_EXPAND_RULES<|

$(LCCSTUB) : $(MATLAB_ROOT)\sys\lcc\mex\lccstub.c
	$(CC) -Fo$(LCCSTUB) $(CFLAGS) "$(subst \,\\,$<)"

$(TARGET): $(OBJLIST) $(LCCSTUB) $(MAKEFILE) $(DIRECTIVES)
	$(LD) $(LINK_FLAGS) $(OBJLIST) $(LINKFLAGSPOST) $(SYS_LIBS) $(DIRECTIVES)
	@cmd /C "echo Build completed using compiler $(EMC_COMPILER)"

#====================================================================

