#
#====================================================================
# gmake makefile fragment for building MEX functions using Intel C++
# Copyright 2007-2010 The MathWorks, Inc.
#====================================================================
#
SHELL = cmd
OBJEXT = obj
CC = $(COMPILER)
LD = $(LINKER)
.SUFFIXES: .$(OBJEXT)

OBJLISTC = $(SRC_FILES:.c=.$(OBJEXT))
OBJLIST  = $(OBJLISTC:.cpp=.$(OBJEXT))

ifeq ($(EMC_COMPILER),intelc11msvs2008)
  TARGETMT = $(TARGET).manifest
  MEX = $(TARGETMT)
else
  MEX = $(TARGET)
endif

target: $(MEX)

ML_INCLUDES = /I "$(subst \,\\,$(MATLAB_ROOT))\extern\include"
ML_INCLUDES+= /I "$(subst \,\\,$(MATLAB_ROOT))\simulink\include"
ML_INCLUDES+= /I "$(subst \,\\,$(MATLAB_ROOT))\toolbox\shared\simtargets"
SYS_INCLUDE = $(ML_INCLUDES)

# Additional includes
|>START_EXPAND_INCLUDES<|
SYS_INCLUDE += /I "$(subst \,\\,|>EXPAND_DIR_NAME<|)"|>END_EXPAND_INCLUDES<|

DIRECTIVES = $(MEX_FILE_NAME_WO_EXT)_mex.arf

COMP_FLAGS = $(COMPFLAGS) -DMX_COMPAT_32
LINK_FLAGS0= $(subst \,\\,$(LINKFLAGS))
LINK_FLAGS = $(filter-out /export:mexFunction, $(LINK_FLAGS0))
LINK_FLAGS += /NODEFAULTLIB:LIBCMT
ifeq ($(EMC_CONFIG),optim)
  COMP_FLAGS += $(OPTIMFLAGS)
  LINK_FLAGS += $(LINKOPTIMFLAGS)
else
  COMP_FLAGS += $(DEBUGFLAGS)
  LINK_FLAGS += $(LINKDEBUGFLAGS)
endif
LINK_FLAGS += /OUT:$(TARGET)
LINK_FLAGS += |>ADDITIONAL_LDFLAGS<|

CFLAGS = |>OPTS<| $(COMP_FLAGS) $(USER_INCLUDE) $(SYS_INCLUDE)
CPPFLAGS = |>CPP_OPTS<| $(CFLAGS)

%.$(OBJEXT) : %.c
	$(CC) $(CFLAGS) "$<"

%.$(OBJEXT) : %.cpp
	$(CC) $(CPPFLAGS) "$<"

# Additional sources

|>START_EXPAND_RULES<|%.$(OBJEXT) : |>EXPAND_DIR_NAME<|/%.c
	$(CC) $(CFLAGS) "$<"

|>END_EXPAND_RULES<|

|>START_EXPAND_RULES<|%.$(OBJEXT) : |>EXPAND_DIR_NAME<|/%.cpp
	$(CC) $(CPPFLAGS) "$<"

|>END_EXPAND_RULES<|

$(TARGET): $(OBJLIST) $(MAKEFILE) $(DIRECTIVES)
	$(LD) $(LINK_FLAGS) $(OBJLIST) $(USER_LIBS) $(SYS_LIBS) @$(DIRECTIVES)
	@cmd /C "echo Build completed using compiler $(EMC_COMPILER)"

$(TARGETMT): $(TARGET)
	mt -outputresource:"$(TARGET);2" -manifest "$(TARGET).manifest"

#====================================================================
