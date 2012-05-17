function hLib = make_ansi_tfl_table

% Copyright 2003-2010 The MathWorks, Inc.

% Create an instance of the Target Function Library table in compliance
% with ANSI C (C89/C90) standard.

% $Revision $
% $Date: 2010/04/21 21:35:14 $

hLib = RTW.TflTable;

hLib.registerCFunctionEntry(100, 1,'sqrt', 'double', 'sqrt', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 1,'sqrt', 'single', 'sqrt', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(100, 1,'floor', 'double', 'floor', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 1,'floor', 'single', 'floor', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(100, 1,'ceil', 'double', 'ceil', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 1,'ceil', 'single', 'ceil', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(100, 1,'log', 'double', 'log', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 1,'log', 'single', 'log', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(100, 1,'log10', 'double', 'log10', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 1,'log10', 'single', 'log10', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(100, 1,'sin', 'double', 'sin', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 1,'sin', 'single', 'sin', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(100, 1,'cos', 'double', 'cos', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 1,'cos', 'single', 'cos', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(100, 1,'tan', 'double', 'tan', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 1,'tan', 'single', 'tan', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(100, 1,'asin', 'double', 'asin', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 1,'asin', 'single', 'asin', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(100, 1,'acos', 'double', 'acos', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 1,'acos', 'single', 'acos', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(100, 1,'atan', 'double', 'atan', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 1,'atan', 'single', 'atan', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(100, 1,'sinh', 'double', 'sinh', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 1,'sinh', 'single', 'sinh', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(100, 1,'cosh', 'double', 'cosh', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 1,'cosh', 'single', 'cosh', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(100, 1,'tanh', 'double', 'tanh', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 1,'tanh', 'single', 'tanh', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(100, 1,'exp', 'double', 'exp', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 1,'exp', 'single', 'exp', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(100, 2,'power', 'double', 'pow', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 2,'power', 'single', 'pow', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 2,'pow', 'double', 'rt_pow$N', 'double', 'rt_pow$N.h','genrtpow.tlc','rt_pow$N');
hLib.registerCFunctionEntry(100, 2,'pow', 'single', 'rt_pow32$N', 'single', 'rt_pow32$N.h','genrtpow32.tlc','rt_pow32$N');

hLib.registerCFunctionEntry(100, 1,'asinh', 'double', 'asinh', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 1,'asinh', 'single', 'asinh', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(100, 1,'acosh', 'double', 'acosh', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 1,'acosh', 'single', 'acosh', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(100, 1,'atanh', 'double', 'atanh', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 1,'atanh', 'single', 'atanh', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(100, 1,'ln', 'double', 'log', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 1,'ln', 'single', 'log', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(100, 2,'fmod', 'double', 'fmod', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(100, 2,'fmod', 'single', 'fmod', 'double', '<math.h>','','');

hLib.registerCFunctionEntry(       100, 1,'abs', 'double', 'fabs', 'double', '<math.h>','','');
hLib.registerCFunctionEntry(       100, 1,'abs', 'single', 'fabs', 'double', '<math.h>','','');

%
% real_T ldexp( real_T, int_T )
%
e = RTW.TflCFunctionEntry;
e.setTflCFunctionEntryParameters('Key', 'ldexp', ...
                                 'Priority', 90, ...
                                 'ImplementationName', 'ldexp', ...
                                 'ImplementationHeaderFile', '<math.h>');

arg = hLib.getTflArgFromString('y1', 'double');
arg.IOType = 'RTW_IO_OUTPUT';
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u1', 'double');
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u2', 'integer');
e.addConceptualArg(arg);

e.copyConceptualArgsToImplementation();
hLib.addEntry( e );

%
% real_T ldexp( real32_T, int_T )
%
e = RTW.TflCFunctionEntry;
e.setTflCFunctionEntryParameters('Key', 'ldexp', ...
                                 'Priority', 90, ...
                                 'ImplementationName', 'ldexp', ...
                                 'ImplementationHeaderFile', '<math.h>');

arg = hLib.getTflArgFromString('y1', 'single');
arg.IOType = 'RTW_IO_OUTPUT';
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u1', 'single');
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u2', 'integer');
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('y1', 'double');
arg.IOType = 'RTW_IO_OUTPUT';
e.Implementation.setReturn(arg);

arg = hLib.getTflArgFromString('u1', 'single');
e.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('u2', 'integer');
e.Implementation.addArgument(arg);

hLib.addEntry( e );

%
% void* memcpy( void*, void*, size_t )
%
e = RTW.TflCFunctionEntry;
e.setTflCFunctionEntryParameters('Key', 'memcpy', ...
                                 'Priority', 90, ...
                                 'ImplementationName', 'memcpy', ...
                                 'ImplementationHeaderFile', '<string.h>', ...
                                 'SideEffects', true);

arg = hLib.getTflArgFromString('y1', 'void*');
arg.IOType = 'RTW_IO_OUTPUT';
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u1', 'void*');
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u2', 'void*');
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u3', 'size_t');
e.addConceptualArg(arg);

e.copyConceptualArgsToImplementation();
hLib.addEntry( e );

%
% void* memset( void*, int, size_t )
%
e = RTW.TflCFunctionEntry;
e.setTflCFunctionEntryParameters('Key', 'memset', ...
                                 'Priority', 90, ...
                                 'ImplementationName', 'memset', ...
                                 'ImplementationHeaderFile', '<string.h>', ...
                                 'SideEffects', true);

arg = hLib.getTflArgFromString('y1', 'void*');
arg.IOType = 'RTW_IO_OUTPUT';
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u1', 'void*');
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u2', 'integer');
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u3', 'size_t');
e.addConceptualArg(arg);

e.copyConceptualArgsToImplementation();
hLib.addEntry( e );

%
% int memcmp( const void*, const void*, size_t )
%
e = RTW.TflCFunctionEntry;
e.setTflCFunctionEntryParameters('Key', 'memcmp', ...
                                 'Priority', 90, ...
                                 'ImplementationName', 'memcmp', ...
                                 'ImplementationHeaderFile', '<string.h>', ...
                                 'SideEffects', true);

arg = hLib.getTflArgFromString('y1', 'integer');
arg.IOType = 'RTW_IO_OUTPUT';
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u1', 'void*');
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u2', 'void*');
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u3', 'size_t');
e.addConceptualArg(arg);

e.copyConceptualArgsToImplementation();
hLib.addEntry( e );

%
% void* malloc( size_t )
%
e = RTW.TflCFunctionEntry;
e.setTflCFunctionEntryParameters('Key', 'malloc', ...
                                 'Priority', 90, ...
                                 'ImplementationName', 'malloc', ...
                                 'ImplementationHeaderFile', '<stdlib.h>', ...
                                 'SideEffects', false);

arg = hLib.getTflArgFromString('y1', 'void*');
arg.IOType = 'RTW_IO_OUTPUT';
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u1', 'size_t');
e.addConceptualArg(arg);

e.copyConceptualArgsToImplementation();
hLib.addEntry( e );

%
% void* calloc( size_t, size_t )
%
e = RTW.TflCFunctionEntry;
e.setTflCFunctionEntryParameters('Key', 'calloc', ...
                                 'Priority', 90, ...
                                 'ImplementationName', 'calloc', ...
                                 'ImplementationHeaderFile', '<stdlib.h>', ...
                                 'SideEffects', false);

arg = hLib.getTflArgFromString('y1', 'void*');
arg.IOType = 'RTW_IO_OUTPUT';
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u1', 'size_t');
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('u2', 'size_t');
e.addConceptualArg(arg);

e.copyConceptualArgsToImplementation();
hLib.addEntry( e );

%
% void free( void* )
%
e = RTW.TflCFunctionEntry;
e.setTflCFunctionEntryParameters('Key', 'free', ...
                                 'Priority', 90, ...
                                 'ImplementationName', 'free', ...
                                 'ImplementationHeaderFile', '<stdlib.h>', ...
                                 'SideEffects', true);

arg = hLib.getTflArgFromString('y1', 'void');
arg.IOType = 'RTW_IO_OUTPUT';
e.addConceptualArg(arg);
                             
arg = hLib.getTflArgFromString('u1', 'void*');
e.addConceptualArg(arg);

e.copyConceptualArgsToImplementation();
hLib.addEntry( e );


% locAddFcnEnt11( hLib, key,          implName,         out,      in1,    hdr,          gencallback,    genfilename )
locAddFcnEnt11(  hLib, 'getNaN',      'rtGetNaN',       'double', 'void', 'rtGetNaN.h', 'genrtnan.tlc', 'rtGetNaN' );
locAddFcnEnt11(  hLib, 'getNaN',      'rtGetNaNF',      'single', 'void', 'rtGetNaN.h', 'genrtnan.tlc', 'rtGetNaN' );
locAddFcnEnt11(  hLib, 'getInf',      'rtGetInf',       'double', 'void', 'rtGetInf.h', 'genrtinf.tlc', 'rtGetInf' );
locAddFcnEnt11(  hLib, 'getInf',      'rtGetInfF',      'single', 'void', 'rtGetInf.h', 'genrtinf.tlc', 'rtGetInf' );
locAddFcnEnt11(  hLib, 'getMinusInf', 'rtGetMinusInf',  'double', 'void', 'rtGetInf.h', 'genrtinf.tlc', 'rtGetInf' );
locAddFcnEnt11(  hLib, 'getMinusInf', 'rtGetMinusInfF', 'single', 'void', 'rtGetInf.h', 'genrtinf.tlc', 'rtGetInf' );

%% Add implementation name resolution map.
% This should be a pair of strings. One for the identifier in the implementation
% name and one for the expansion.
% Right now, '$N' is the symbol for SupportNonFinite. If SupportNonFinite is
% enabled, then '$N' will be expanded to the indicated string.
hLib.StringResolutionMap = {'$N','_snf'};

function locAddFcnEnt11( hLib, key, implName, out, in1, hdr, gencallback, genfilename )
  if isempty(hLib)
    return;
  end
  
  e = RTW.TflCFunctionEntry;
  e.setTflCFunctionEntryParameters('Key', key, ...
                                   'Priority', 90, ...
                                   'ImplementationName', implName, ...
                                   'ImplementationHeaderFile', hdr, ...
                                   'GenCallback', gencallback, ...
                                   'GenFileName', genfilename);

  arg = hLib.getTflArgFromString('y1', out);
  arg.IOType = 'RTW_IO_OUTPUT';
  e.addConceptualArg(arg);

  arg = hLib.getTflArgFromString('u1', in1);
  e.addConceptualArg(arg);

  e.copyConceptualArgsToImplementation();
  hLib.addEntry( e );

% EOF
