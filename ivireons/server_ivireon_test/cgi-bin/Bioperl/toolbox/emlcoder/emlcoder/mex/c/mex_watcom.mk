#
#====================================================================
# gmake makefile fragment for building MEX functions using Watcom
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
OBJFILE = $(subst .$(OBJEXT) ,.$(OBJEXT) file ,$(OBJLIST))

target: $(TARGET)

ML_INCLUDES = /I="$(subst \,\\,$(MATLAB_ROOT))\extern\include"
ML_INCLUDES+= /I="$(subst \,\\,$(MATLAB_ROOT))\simulink\include"
ML_INCLUDES+= /I="$(subst \,\\,$(MATLAB_ROOT))\toolbox\shared\simtargets"
SYS_INCLUDE = $(ML_INCLUDES)

# Additional includes
|>START_EXPAND_INCLUDES<|
SYS_INCLUDE += /I="$(subst \,\\,|>EXPAND_DIR_NAME<|)"|>END_EXPAND_INCLUDES<|

USR_OBJS = $(SYS_LIBS:"%.obj"=file %.obj)
USR_LIBS = $(USR_OBJS:"%.lib"=library %.lib)

ALL_LIBS = $(USR_LIBS)

DIRECTIVES = $(MEX_FILE_NAME_WO_EXT)_mex.lnk

COMP_FLAGS = $(COMPFLAGS) -DMX_COMPAT_32
ifeq ($(EMC_CONFIG),optim)
  COMP_FLAGS += $(OPTIMFLAGS)
  LINK_FLAGS = $(LINKOPTIMFLAGS)
else
  COMP_FLAGS += $(DEBUGFLAGS)
  LINK_FLAGS = $(LINKDEBUGFLAGS)
endif
LINK_FLAGS += $(subst \,\\,$(LINKFLAGS))
LINK_FLAGS += name $(TARGET)
LINK_FLAGS += |>ADDITIONAL_LDFLAGS<|

CFLAGS = |>OPTS<| $(COMP_FLAGS) $(USER_INCLUDE) $(SYS_INCLUDE)
CPPFLAGS = |>CPP_OPTS<| $(CFLAGS)

%.$(OBJEXT) : %.c
	$(CC) $(CFLAGS) "$<"

%.$(OBJEXT) : %.cpp
	$(CC) $(CPPFLAGS) "$<"

# Additional sources

|>START_EXPAND_RULES<|%.$(OBJEXT) : |>EXPAND_DIR_NAME<|/%.c
	$(CC) $(CFLAGS) "$(subst /,\,$<)"

|>END_EXPAND_RULES<|

|>START_EXPAND_RULES<|%.$(OBJEXT) : |>EXPAND_DIR_NAME<|/%.cpp
	$(CC) $(CPPFLAGS) "$(subst /,\,$<)"

|>END_EXPAND_RULES<|

$(TARGET): $(OBJLIST) $(MAKEFILE) $(DIRECTIVES)
	$(LD) $(LINK_FLAGS) file $(OBJFILE) $(ALL_LIBS) @$(DIRECTIVES)
	@echo Build completed using compiler $(EMC_COMPILER)

#====================================================================

