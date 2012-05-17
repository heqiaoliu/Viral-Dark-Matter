function hLib = tfl_table_customentry
 
% Copyright 2009 The MathWorks, Inc.
 
% $Revision $
% $Date: 2009/11/13 04:57:15 $
 
hLib = RTW.TflTable;

locAddCastEnt(  hLib, 'RTW_OP_CAST', 'custom_cast', 'uint8', 'uint16');
locAddFcnEnt(  hLib, 'sin', 'custom_sin', 'double', 'double' );


%% Local helper functions

function locAddCastEnt( hLib, key, implName, out, in1 )
  if isempty(hLib)
    return;
  end
  
  % Create an instance of the custom TFL cast operation entry
  hEnt = CustomTflEntry.TflCustomCastEntry;
  locSetOpProps( hEnt, key, implName );
  locAddArgsToEntry( hLib, hEnt, out, in1 );
  hLib.addEntry( hEnt );
    
%%

function locSetOpProps( hEnt, key, implName)
  if isempty( hEnt )
    return;
  end
  hEnt.setTflCOperationEntryParameters( ...
    'Key',                      key, ...
    'Priority',                 30, ...
    'SaturationMode',           'RTW_SATURATE_ON_OVERFLOW', ...
    'RoundingMode',             'RTW_ROUND_ZERO', ...
    'ImplementationName',       implName, ...
    'ImplementationHeaderFile', [implName '.h'], ...
    'ImplementationSourceFile', [implName '.c']);

%%  
  
function locAddArgsToEntry( hLib, hEnt, out, in1 )
  if isempty(hLib) || isempty( hEnt )
    return;
  end

  % Specify operands and result
  arg = hLib.getTflArgFromString('y1',out);
  arg.IOType = 'RTW_IO_OUTPUT';
  arg.CheckSlope = false;
  arg.CheckBias = false;
  hEnt.addConceptualArg(arg);

  arg = hLib.getTflArgFromString('u1',in1);
  arg.CheckSlope = false;
  arg.CheckBias = false;
  hEnt.addConceptualArg(arg);

  % Specify replacement function Signature
  hEnt.copyConceptualArgsToImplementation();

  % Add fraction length arguments. Actual values will be set during code generation.                                    
  arg = hLib.getTflArgFromString('fraction_in','int16', 0.0);
  hEnt.Implementation.addArgument(arg);
  arg = hLib.getTflArgFromString('fraction_out','int16', 0.0);
  hEnt.Implementation.addArgument(arg);

%%

function locAddFcnEnt( hLib, key, implName, out, in1 )
  if isempty(hLib)
    return;
  end
  
  % Create an instance of the custom TFL function entry
  hEnt = CustomTflEntry.TflCustomFunctionEntry;
  hEnt.setTflCFunctionEntryParameters( ...
    'Key',                      key, ...
    'Priority',                 30, ...
    'ImplementationName',       implName, ...
    'ImplementationHeaderFile', [implName '.h'], ...
    'ImplementationSourceFile', [implName '.c']);
  
  arg = hLib.getTflArgFromString('y1',out);
  arg.IOType = 'RTW_IO_OUTPUT';
  hEnt.addConceptualArg(arg);

  arg = hLib.getTflArgFromString('u1',in1);
  hEnt.addConceptualArg(arg);

  hEnt.copyConceptualArgsToImplementation();
  hLib.addEntry( hEnt );
%%

%EOF

