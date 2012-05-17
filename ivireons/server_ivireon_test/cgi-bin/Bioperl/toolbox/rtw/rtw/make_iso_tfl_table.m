function hLib = make_iso_tfl_table

% Copyright 2003-2009 The MathWorks, Inc.

% $Revision $
% $Date: 2009/03/05 18:51:28 $

  hLib = RTW.TflTable;

 
  hLib.registerCFunctionEntry(99, 1,'fix', 'double', 'trunc', 'double', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 2,'rem', 'double', 'fmod', 'double', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 2,'min', 'double', 'fmin', 'double', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 2,'max', 'double', 'fmax', 'double', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 2,'hypot', 'double', 'hypot', 'double', '<math.h>','','');
  %%
  %% --- single datatype
  %%

  hLib.registerCFunctionEntry(99, 1,'floor', 'single', 'floorf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'ceil', 'single', 'ceilf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'abs', 'single', 'fabsf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'exp', 'single', 'expf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'log', 'single', 'logf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'log10', 'single', 'log10f', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'sin', 'single', 'sinf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'cos', 'single', 'cosf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'tan', 'single', 'tanf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'asin', 'single', 'asinf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'acos', 'single', 'acosf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'atan', 'single', 'atanf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'sinh', 'single', 'sinhf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'cosh', 'single', 'coshf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'tanh', 'single', 'tanhf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'sqrt', 'single', 'sqrtf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 2,'fmod', 'single', 'fmodf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'round', 'single', 'roundf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'fix', 'single', 'truncf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 2,'pow', 'single', 'powf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 2,'power', 'single', 'powf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'ln', 'single', 'logf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 2,'rem', 'single', 'fmodf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 2,'min', 'single', 'fminf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 2,'max', 'single', 'fmaxf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 2,'hypot', 'single', 'hypotf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'asinh', 'single', 'asinhf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'acosh', 'single', 'acoshf', 'single', '<math.h>','','');
  hLib.registerCFunctionEntry(99, 1,'atanh', 'single', 'atanhf', 'single', '<math.h>','','');

%
% real32_T ldexp( real32_T, int_T )
%
e = RTW.TflCFunctionEntry;
e.setTflCFunctionEntryParameters('Key', 'ldexp', ...
                                 'Priority', 90, ...
                                 'ImplementationName', 'ldexpf', ...
                                 'ImplementationHeaderFile', '<math.h>');

arg = hLib.getTflArgFromString('y1', 'single');
arg.IOType = 'RTW_IO_OUTPUT';
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u1', 'single');
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u2', 'integer');
e.addConceptualArg(arg);

e.copyConceptualArgsToImplementation();
hLib.addEntry( e );

% EOF
