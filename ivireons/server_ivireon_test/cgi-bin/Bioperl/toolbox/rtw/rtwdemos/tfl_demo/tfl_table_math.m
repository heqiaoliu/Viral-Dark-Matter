function hLib = tfl_table_math()
%TFL_TABLE_MATH - Describe entries for a Target Function Library table.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $
% $Date: 2008/06/20 08:12:14 $

hLib = RTW.TflTable;


% Create entries for double data type math function replacements
hLib.registerCFunctionEntry(100, 1,'cos', 'double', 'cos_dbl', 'double', '<cos_dbl.h>','','');
hLib.registerCFunctionEntry(100, 1,'sin', 'double', 'sin_dbl', 'double', '<sin_dbl.h>','','');
hLib.registerCFunctionEntry(100, 1,'tan', 'double', 'tan_dbl', 'double', '<tan_dbl.h>','','');
hLib.registerCFunctionEntry(100, 1,'acos', 'double', 'acos_dbl', 'double', '<acos_dbl.h>','','');
hLib.registerCFunctionEntry(100, 1,'asin', 'double', 'asin_dbl', 'double', '<asin_dbl.h>','','');
hLib.registerCFunctionEntry(100, 1,'atan', 'double', 'atan_dbl', 'double', '<atan_dbl.h>','','');
hLib.registerCFunctionEntry(100, 1,'cosh', 'double', 'cosh_dbl', 'double', '<cosh_dbl.h>','','');
hLib.registerCFunctionEntry(100, 1,'sinh', 'double', 'sinh_dbl', 'double', '<sinh_dbl.h>','','');
hLib.registerCFunctionEntry(100, 1,'tanh', 'double', 'tanh_dbl', 'double', '<tanh_dbl.h>','','');
hLib.registerCFunctionEntry(100, 1,'exp', 'double', 'exp_dbl', 'double', '<exp_dbl.h>','','');
hLib.registerCFunctionEntry(100, 1,'log', 'double', 'log_dbl', 'double', '<log_dbl.h>','','');
hLib.registerCFunctionEntry(100, 1,'log10', 'double', 'log10_dbl', 'double', '<log10_dbl.h>','','');
hLib.registerCFunctionEntry(100, 1,'sqrt', 'double', 'sqrt_dbl', 'double', '<sqrt_dbl.h>','','');
hLib.registerCFunctionEntry(100, 1,'ceil', 'double', 'ceil_dbl', 'double', '<ceil_dbl.h>','','');
hLib.registerCFunctionEntry(100, 1,'abs', 'double', 'fabs_dbl', 'double', '<fabs_dbl.h>','','');
hLib.registerCFunctionEntry(100, 1,'floor', 'double', 'floor_dbl', 'double', '<floor_dbl.h>','','');
hLib.registerCFunctionEntry(100, 2,'power', 'double', 'pow_dbl', 'double', 'pow_dbl.h','','');
hLib.registerCFunctionEntry(100, 2,'pow', 'double', 'pow_dbl', 'double', 'pow_dbl.h','','');


% Create entries for single data type math function replacements
hLib.registerCFunctionEntry(100, 1,'cos', 'single', 'cos_sgl', 'single', '<cos_sgl.h>','','');
hLib.registerCFunctionEntry(100, 1,'sin', 'single', 'sin_sgl', 'single', '<sin_sgl.h>','','');
hLib.registerCFunctionEntry(100, 1,'tan', 'single', 'tan_sgl', 'single', '<tan_sgl.h>','','');
hLib.registerCFunctionEntry(100, 1,'acos', 'single', 'acos_sgl', 'single', '<acos_sgl.h>','','');
hLib.registerCFunctionEntry(100, 1,'asin', 'single', 'asin_sgl', 'single', '<asin_sgl.h>','','');
hLib.registerCFunctionEntry(100, 1,'atan', 'single', 'atan_sgl', 'single', '<atan_sgl.h>','','');
hLib.registerCFunctionEntry(100, 1,'cosh', 'single', 'cosh_sgl', 'single', '<cosh_sgl.h>','','');
hLib.registerCFunctionEntry(100, 1,'sinh', 'single', 'sinh_sgl', 'single', '<sinh_sgl.h>','','');
hLib.registerCFunctionEntry(100, 1,'tanh', 'single', 'tanh_sgl', 'single', '<tanh_sgl.h>','','');
hLib.registerCFunctionEntry(100, 1,'exp', 'single', 'exp_sgl', 'single', '<exp_sgl.h>','','');
hLib.registerCFunctionEntry(100, 1,'log', 'single', 'log_sgl', 'single', '<log_sgl.h>','','');
hLib.registerCFunctionEntry(100, 1,'log10', 'single', 'log10_sgl', 'single', '<log10_sgl.h>','','');
hLib.registerCFunctionEntry(100, 1,'sqrt', 'single', 'sqrt_sgl', 'single', '<sqrt_sgl.h>','','');
hLib.registerCFunctionEntry(100, 1,'ceil', 'single', 'ceil_sgl', 'single', '<ceil_sgl.h>','','');
hLib.registerCFunctionEntry(100, 1,'abs', 'single', 'fabs_sgl', 'single', '<fabs_sgl.h>','','');
hLib.registerCFunctionEntry(100, 1,'floor', 'single', 'floor_sgl', 'single', '<floor_sgl.h>','','');
hLib.registerCFunctionEntry(100, 2,'power', 'single', 'pow_sgl', 'single', 'pow_sgl.h','','');
hLib.registerCFunctionEntry(100, 2,'pow', 'single', 'pow_sgl', 'single', 'pow_sgl.h','','');

%% Register non-finite number support utility functions
% locAddFcnEnt11( hLib, key,          implName,        out,      in1,    hdr )
locAddFcnEnt11(  hLib, 'getNaN',      'getNaN',       'double', 'void', 'nonfinitesupport.h' );
locAddFcnEnt11(  hLib, 'getNaN',      'getNaNF',      'single', 'void', 'nonfinitesupport.h' );
locAddFcnEnt11(  hLib, 'getInf',      'getInf',       'double', 'void', 'nonfinitesupport.h' );
locAddFcnEnt11(  hLib, 'getInf',      'getInfF',      'single', 'void', 'nonfinitesupport.h' );
locAddFcnEnt11(  hLib, 'getMinusInf', 'getMinusInf',  'double', 'void', 'nonfinitesupport.h' );
locAddFcnEnt11(  hLib, 'getMinusInf', 'getMinusInfF', 'single', 'void', 'nonfinitesupport.h' );

%
% void* memcpy( void*, void*, size_t )
%
e = RTW.TflCFunctionEntry;
e.setTflCFunctionEntryParameters('Key', 'memcpy', ...
                                 'Priority', 90, ...
                                 'ImplementationName', 'memcpy_int', ...
                                 'ImplementationHeaderFile', 'memcpy_int.h', ...
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

%% Local Functions
function locAddFcnEnt11( hLib, key, implName, out, in1, hdr )
  if isempty(hLib)
    return;
  end
  
  e = RTW.TflCFunctionEntry;
  e.setTflCFunctionEntryParameters('Key', key, ...
                                   'Priority', 90, ...
                                   'ImplementationName', implName, ...
                                   'ImplementationHeaderFile', hdr);

  arg = hLib.getTflArgFromString('y1', out);
  arg.IOType = 'RTW_IO_OUTPUT';
  e.addConceptualArg(arg);

  arg = hLib.getTflArgFromString('u1', in1);
  e.addConceptualArg(arg);

  e.copyConceptualArgsToImplementation();
  hLib.addEntry( e );

  %EOF
  