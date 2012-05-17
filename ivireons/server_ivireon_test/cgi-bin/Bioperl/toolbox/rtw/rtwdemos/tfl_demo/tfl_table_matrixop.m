function hLib = tfl_table_matrixop

% Copyright 2008-2009 The MathWorks, Inc.

% $Revision $
% $Date: 2009/11/13 04:57:16 $

hLib = RTW.TflTable;

%% Basic Matrix Operations (not BLAS)
LibPath = fullfile(matlabroot,...
                   'toolbox',...
                   'rtw',...
                   'rtwdemos',...
                   'tfl_demo');
               
types = { 'single',  'double',  'int8',  'int16',  'int32',  'uint8',  'uint16',  'uint32', ...
         'csingle', 'cdouble', 'cint8', 'cint16', 'cint32', 'cuint8', 'cuint16', 'cuint32'};
for i=1:length(types)
  % Matrix dimensions can be entered as an allowable range of dimensions.
  % Format: [Dim1Min Dim2Min ... DimNMin; Dim1Max Dim2Max ... DimNMax]
  % Example: [2 2; inf inf] means "any 2D matrix of size 2x2 or larger"
  % Here, however, they are being entered as exact values, not ranges.
  % [2 2] means that the matrix dimension must be exactly 2x2
  
  %locAddMatrixOpEnt( hLib,  key,           implName,                       out,     outDims, in1,    in1Dims, in2,    in2Dims, LibPath )    
  locAddMatrixOpEnt(  hLib, 'RTW_OP_ADD',   ['matrix_sum_2x2_'   types{i}], types{i}, [2 2], types{i}, [2 2], types{i}, [2 2],  LibPath );
  locAddMatrixOpEnt(  hLib, 'RTW_OP_ADD',   ['matrix_sum_3x3_'   types{i}], types{i}, [3 3], types{i}, [3 3], types{i}, [3 3],  LibPath );
  locAddMatrixOpEnt(  hLib, 'RTW_OP_ADD',   ['matrix_sum_4x4_'   types{i}], types{i}, [4 4], types{i}, [4 4], types{i}, [4 4],  LibPath );
  locAddMatrixOpEnt(  hLib, 'RTW_OP_MINUS', ['matrix_sub_2x2_'   types{i}], types{i}, [2 2], types{i}, [2 2], types{i}, [2 2],  LibPath );
  locAddMatrixOpEnt(  hLib, 'RTW_OP_MINUS', ['matrix_sub_3x3_'   types{i}], types{i}, [3 3], types{i}, [3 3], types{i}, [3 3],  LibPath );
  locAddMatrixOpEnt(  hLib, 'RTW_OP_MINUS', ['matrix_sub_4x4_'   types{i}], types{i}, [4 4], types{i}, [4 4], types{i}, [4 4],  LibPath );
  locAddMatrixOpEnt(  hLib, 'RTW_OP_TRANS', ['matrix_trans_2x2_' types{i}], types{i}, [2 2], types{i}, [2 2], '',       [],     LibPath );
  locAddMatrixOpEnt(  hLib, 'RTW_OP_TRANS', ['matrix_trans_3x3_' types{i}], types{i}, [3 3], types{i}, [3 3], '',       [],     LibPath );
  locAddMatrixOpEnt(  hLib, 'RTW_OP_TRANS', ['matrix_trans_4x4_' types{i}], types{i}, [4 4], types{i}, [4 4], '',       [],     LibPath );
  if types{i}(1) == 'c' && types{i}(2) ~= 'u'
      locAddMatrixOpEnt(  hLib, 'RTW_OP_HERMITIAN', ['matrix_herm_2x2_' types{i}], types{i}, [2 2], types{i}, [2 2], '',       [],     LibPath );
      locAddMatrixOpEnt(  hLib, 'RTW_OP_HERMITIAN', ['matrix_herm_3x3_' types{i}], types{i}, [3 3], types{i}, [3 3], '',       [],     LibPath );
      locAddMatrixOpEnt(  hLib, 'RTW_OP_HERMITIAN', ['matrix_herm_4x4_' types{i}], types{i}, [4 4], types{i}, [4 4], '',       [],     LibPath );
      locAddMatrixOpEnt(  hLib, 'RTW_OP_CONJUGATE', ['matrix_conj_2x2_' types{i}], types{i}, [2 2], types{i}, [2 2], '',       [],     LibPath );
      locAddMatrixOpEnt(  hLib, 'RTW_OP_CONJUGATE', ['matrix_conj_3x3_' types{i}], types{i}, [3 3], types{i}, [3 3], '',       [],     LibPath );
      locAddMatrixOpEnt(  hLib, 'RTW_OP_CONJUGATE', ['matrix_conj_4x4_' types{i}], types{i}, [4 4], types{i}, [4 4], '',       [],     LibPath );
  end
end

% Mixed types entries
locAddMatrixOpEnt(  hLib, 'RTW_OP_ADD',   'matrix_sum_3x3_int8_int16', 'int16', [3 3], 'int8', [3 3], 'int16', [3 3],  LibPath );
locAddMatrixOpEnt(  hLib, 'RTW_OP_MINUS',   'matrix_sub_3x3_single_double', 'double', [3 3], 'single', [3 3], 'double', [3 3],  LibPath );


%% Local Function
function locAddMatrixOpEnt( hLib, key, implName, out, outDims, in1, in1Dims, in2, in2Dims, LibPath )
  if isempty(hLib)
    return;
  end
  
  hEnt = RTW.TflCOperationEntry;
  locSetOpProps( hEnt, key, implName, LibPath );
  locAddMatrixArgsToEntry( hLib, hEnt, out, outDims, in1, in1Dims, in2, in2Dims );
  hLib.addEntry( hEnt );
%
function locSetOpProps( hEnt, key, implName, LibPath )
  if isempty( hEnt )
    return;
  end
  hEnt.setTflCOperationEntryParameters( ...
    'Key',                      key, ...
    'Priority',                 30, ...
    'SaturationMode',           'RTW_SATURATE_UNSPECIFIED', ...
    'ImplementationName',       implName, ...
    'ImplementationHeaderFile', 'MatrixMath.h', ...
    'ImplementationSourceFile', 'MatrixMath.c', ...
    'ImplementationHeaderPath', LibPath, ...
    'ImplementationSourcePath', LibPath, ...
    'AdditionalIncludePaths',   {LibPath}, ...
    'GenCallback',              'RTW.copyFileToBuildDir', ...
    'SideEffects',              true);

%
function locAddMatrixArgsToEntry( hLib, hEnt, out, outDims, in1, in1Dims, in2, in2Dims )
  if isempty(hLib) || isempty( hEnt )
    return;
  end

  % Specify operands and result
  hEnt.createAndAddConceptualArg('RTW.TflArgMatrix',...
                            'Name',         'y1', ...
                            'IOType',       'RTW_IO_OUTPUT', ...
                            'BaseType',     out, ...
                            'DimRange',     outDims);

  hEnt.createAndAddConceptualArg('RTW.TflArgMatrix',...
                            'Name',         'u1', ...
                            'BaseType',     in1, ...
                            'DimRange',     in1Dims);
  if ~isempty(in2)                        
    hEnt.createAndAddConceptualArg('RTW.TflArgMatrix',...
                            'Name',         'u2', ...
                            'BaseType',     in2, ...
                            'DimRange',     in2Dims);
  end
  
  % Specify replacement function Signature
  arg = hLib.getTflArgFromString('y2','void');
  arg.IOType = 'RTW_IO_OUTPUT';
  hEnt.Implementation.setReturn(arg);

  arg = hLib.getTflArgFromString('u1',[in1 '*']);
  hEnt.Implementation.addArgument(arg);

  if ~isempty(in2)                        
    arg = hLib.getTflArgFromString('u2',[in2 '*']);
    hEnt.Implementation.addArgument(arg);
  end

  arg = hLib.getTflArgFromString('y1',[out '*']);
  arg.IOType = 'RTW_IO_OUTPUT';
  hEnt.Implementation.addArgument(arg);
    
%EOF
