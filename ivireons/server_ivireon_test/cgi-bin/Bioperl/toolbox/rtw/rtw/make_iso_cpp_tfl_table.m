function hLib = make_iso_cpp_tfl_table

% Copyright 2003-2009 The MathWorks, Inc.

% Create an instance of the Target Function Library table in compliance
% with ANSI C (C89/C90) standard.

% $Revision $
% $Date: 2009/08/23 19:09:18 $

hLib = RTW.TflTable;

hLib.registerCPPFunctionEntry(97, 1,'abs', 'single', 'abs', 'single', '<cmath>','','','std');
hLib.registerCPPFunctionEntry(97, 1,'abs', 'double', 'abs', 'double', '<cmath>','','','std');
hLib.registerCPPFunctionEntry(97, 1,'acos', 'single', 'acos', 'single', '<cmath>','','','std');
hLib.registerCPPFunctionEntry(97, 1,'asin', 'single', 'asin', 'single', '<cmath>','','','std');
hLib.registerCPPFunctionEntry(97, 1,'atan', 'single', 'atan', 'single', '<cmath>','','','std');
%atan2 is in make_private_iso_cpp_tfl_table, following the convention of C counterpart
%hLib.registerCPPFunctionEntry(97, 2,'atan2', 'single', 'rt_atan232$N', 'single', 'rt_atan232$N.h','genrtatan232.tlc','rt_atan232$N','std');
hLib.registerCPPFunctionEntry(97, 1,'ceil', 'single', 'ceil', 'single', '<cmath>','','','std');
hLib.registerCPPFunctionEntry(97, 1,'cos', 'single', 'cos', 'single', '<cmath>','','','std');
hLib.registerCPPFunctionEntry(97, 1,'cosh', 'single', 'cosh', 'single', '<cmath>','','','std');
hLib.registerCPPFunctionEntry(97, 1,'exp', 'single', 'exp', 'single', '<cmath>','','','std');
hLib.registerCPPFunctionEntry(97, 1,'floor','single', 'floor', 'single', '<cmath>','','','std');
hLib.registerCPPFunctionEntry(97, 2,'fmod','single', 'fmod', 'single', '<cmath>','','','std');

% frexp is in make_private_iso_cpp_tfl_table.m, following the convention of the C counterpart 

%
% real32_T ldexp( real32_T, int_T )
%
e = RTW.TflCFunctionEntry;
e.setTflCFunctionEntryParameters('Key', 'ldexp', ...
                                 'Priority', 89, ...
                                 'ImplementationName', 'ldexp', ...
                                 'ImplementationHeaderFile', '<cmath>');
e.enableCPP();
e.setNameSpace('std');

arg = hLib.getTflArgFromString('y1', 'single');
arg.IOType = 'RTW_IO_OUTPUT';
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u1', 'single');
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u2', 'integer');
e.addConceptualArg(arg);

e.copyConceptualArgsToImplementation();
hLib.addEntry( e );


hLib.registerCPPFunctionEntry(97, 1,'log', 'single', 'log', 'single', '<cmath>','','','std');
hLib.registerCPPFunctionEntry(97, 1,'log10', 'single', 'log10', 'single', '<cmath>','','','std');

% Why modf is missing from all of the TFL tables? TODO

% pow has a row_pos in make_private_iso_cpp_tfl_table, following the convention of C counterpart

hLib.registerCPPFunctionEntry(97, 2,'pow', 'single', 'pow', 'single', '<cmath>','','','std');

% how about pow(float,int)? TODO
% how about pow(double,int)? TODO

hLib.registerCPPFunctionEntry(97, 1,'sin', 'single', 'sin', 'single', '<cmath>','','','std');
hLib.registerCPPFunctionEntry(97, 1,'sinh', 'single', 'sinh', 'single', '<cmath>','','','std');
hLib.registerCPPFunctionEntry(97, 1,'sqrt', 'single', 'sqrt', 'single', '<cmath>','','','std');
hLib.registerCPPFunctionEntry(97, 1,'tan', 'single', 'tan', 'single', '<cmath>','','','std');
hLib.registerCPPFunctionEntry(97, 1,'tanh', 'single', 'tanh', 'single', '<cmath>','','','std');


%From the ANSI C table. Adapted to force std::fcnname for conformance
hLib.registerCPPFunctionEntry(97, 1,'sqrt', 'double', 'sqrt', 'double', '<cmath>','','','std');

hLib.registerCPPFunctionEntry(97, 1,'floor', 'double', 'floor', 'double', '<cmath>','','','std');

hLib.registerCPPFunctionEntry(97, 1,'ceil', 'double', 'ceil', 'double', '<cmath>','','','std');

hLib.registerCPPFunctionEntry(97, 1,'log', 'double', 'log', 'double', '<cmath>','','','std');

hLib.registerCPPFunctionEntry(97, 1,'log10', 'double', 'log10', 'double', '<cmath>','','','std');

hLib.registerCPPFunctionEntry(97, 1,'sin', 'double', 'sin', 'double', '<cmath>','','','std');

hLib.registerCPPFunctionEntry(97, 1,'cos', 'double', 'cos', 'double', '<cmath>','','','std');

hLib.registerCPPFunctionEntry(97, 1,'tan', 'double', 'tan', 'double', '<cmath>','','','std');

hLib.registerCPPFunctionEntry(97, 1,'asin', 'double', 'asin', 'double', '<cmath>','','','std');

hLib.registerCPPFunctionEntry(97, 1,'acos', 'double', 'acos', 'double', '<cmath>','','','std');

hLib.registerCPPFunctionEntry(97, 1,'atan', 'double', 'atan', 'double', '<cmath>','','','std');

hLib.registerCPPFunctionEntry(97, 1,'sinh', 'double', 'sinh', 'double', '<cmath>','','','std');

hLib.registerCPPFunctionEntry(97, 1,'cosh', 'double', 'cosh', 'double', '<cmath>','','','std');

hLib.registerCPPFunctionEntry(97, 1,'tanh', 'double', 'tanh', 'double', '<cmath>','','','std');

hLib.registerCPPFunctionEntry(97, 1,'exp', 'double', 'exp', 'double', '<cmath>','','','std');

hLib.registerCPPFunctionEntry(97, 2,'power', 'double', 'pow', 'double', '<cmath>','','','std');

hLib.registerCPPFunctionEntry(97, 1,'ln', 'double', 'log', 'double', '<cmath>','','','std');

hLib.registerCPPFunctionEntry(97, 2,'fmod', 'double', 'fmod', 'double', '<cmath>','','','std');


%
% real_T ldexp( real_T, int_T )
%
e = RTW.TflCFunctionEntry;
e.setTflCFunctionEntryParameters('Key', 'ldexp', ...
                                 'Priority', 90, ...
                                 'ImplementationName', 'ldexp', ...
                                 'ImplementationHeaderFile', '<cmath>');
e.enableCPP();
e.setNameSpace('std');

arg = hLib.getTflArgFromString('y1', 'double');
arg.IOType = 'RTW_IO_OUTPUT';
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u1', 'double');
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u2', 'integer');
e.addConceptualArg(arg);

e.copyConceptualArgsToImplementation();
hLib.addEntry( e );

% EOF
