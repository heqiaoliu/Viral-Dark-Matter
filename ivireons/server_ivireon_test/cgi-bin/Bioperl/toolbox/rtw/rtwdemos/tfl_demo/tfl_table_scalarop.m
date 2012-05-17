function hLib = tfl_table_scalarop

%   Copyright 2009 The MathWorks, Inc.

hLib = RTW.TflTable;

%% Basic Matrix Operations (not BLAS)
LibPath = fullfile(matlabroot,...
                   'toolbox',...
                   'rtw',...
                   'rtwdemos',...
                   'tfl_demo');          
               
types = { 'csingle', 'cdouble', 'cint8', 'cint16', 'cint32', 'cuint8', 'cuint16', 'cuint32', ...
   'single',  'double',  'int8',  'int16',  'int32',  'uint8',  'uint16', 'uint32'};

for i=1:length(types)
   %locAddMatrixOpEnt( hLib,  key,           implName,                    out,     in1,    in2,      LibPath )
   locAddScalarOpEnt(  hLib, 'RTW_OP_ADD',  ['scalar_sum_'   types{i}], types{i}, types{i}, types{i}, LibPath );
   locAddScalarOpEnt(  hLib, 'RTW_OP_MINUS',['scalar_minus_' types{i}], types{i}, types{i}, types{i}, LibPath );
   
   if types{i}(1) == 'c' && types{i}(2) ~= 'u'
       locAddScalarOpEnt(  hLib, 'RTW_OP_CONJUGATE',  ['scalar_conj_'   types{i}], types{i}, types{i}, '', LibPath );
   end
end
%locAddMatrixOpEnt( hLib,  key,                implName,               out,     in1,    in2,      LibPath )
locAddScalarOpEnt(  hLib, 'RTW_OP_MUL',  ['scalar_mult_'  'cdouble'], 'cdouble', 'cdouble', 'cdouble', LibPath );
locAddScalarOpEnt(  hLib, 'RTW_OP_CAST', ['scalar_cast_'  'double'], 'single', 'double', '', LibPath );
locAddScalarOpEnt(  hLib, 'RTW_OP_SRA',  ['scalar_sra_'   'int16'], 'int16', 'int16', 'uint8', LibPath );
locAddScalarOpEnt(  hLib, 'RTW_OP_SRL',  ['scalar_srl_'   'uint32'], 'uint32', 'uint32', 'uint8', LibPath );
locAddScalarOpEnt(  hLib, 'RTW_OP_SL',   ['scalar_sl_'    'int16'], 'int16', 'int16', 'uint8', LibPath );


  function locAddScalarOpEnt( hLib, key, implName, out,  in1,  in2, LibPath )
  if isempty(hLib)
    return;
  end
  
  hEnt = RTW.TflCOperationEntry;
  locSetOpProps( hEnt, key, implName, LibPath );
  locAddScalarArgsToEntry( hLib, hEnt, out, in1, in2);
  hLib.addEntry( hEnt );
    
  function locSetOpProps( hEnt, key, implName, LibPath )
  if isempty( hEnt )
    return;
  end
  hEnt.setTflCOperationEntryParameters( ...
    'Key',                      key, ...
    'Priority',                 30, ...
    'ImplementationName',       implName, ...
    'ImplementationHeaderFile', 'ScalarMath.h', ...
    'ImplementationSourceFile', 'ScalarMath.c', ...
    'SaturationMode',           'RTW_WRAP_ON_OVERFLOW', ... 
    'ImplementationHeaderPath', LibPath, ...
    'ImplementationSourcePath', LibPath, ...
    'AdditionalIncludePaths',   {LibPath}, ... 
    'GenCallback',              'RTW.copyFileToBuildDir', ...
    'SideEffects',              true,...
    'AcceptExprInput',          true);  

function locAddScalarArgsToEntry( hLib, hEnt, out, in1, in2 )
  if isempty(hLib) || isempty( hEnt )
    return;
  end
   
   a = hLib.getTflArgFromString('y1', out);
   a.IOType = 'RTW_IO_OUTPUT';
   hEnt.addConceptualArg(a);
   a = hLib.getTflArgFromString('u1', in1);
   hEnt.addConceptualArg(a);
   
   if ~isempty(in2)
     a = hLib.getTflArgFromString('u2', in2);
     hEnt.addConceptualArg(a);
   end

   a=hLib.getTflArgFromString('y2', 'void');
   a.IOType = 'RTW_IO_OUTPUT';
   hEnt.Implementation.setReturn(a);
  
   
   a=hLib.getTflArgFromString('u1', in1);
   hEnt.Implementation.addArgument(a);
   
   if ~isempty(in2)
     a=hLib.getTflArgFromString('u2', in2);
     hEnt.Implementation.addArgument(a); 
   end
   
   a=hLib.getTflArgFromString('y1', [out '*']);
   a.IOType = 'RTW_IO_OUTPUT';
   hEnt.Implementation.addArgument(a); 
   
