function hLib = tfl_table_tmwblas
% Copyright 2008-2009 The MathWorks, Inc.

% $Revision: 1.1.6.2 $
% $Date: 2009/11/13 04:57:18 $

hLib = RTW.TflTable;

arch = computer('arch');
if ~ispc
    LibPath = fullfile('$(MATLAB_ROOT)',...
        'bin', ...
        arch);
else
    % Use Stateflow to get the compiler info
    compilerInfo = sf('Private','compilerman','get_compiler_info');
    compilerName = compilerInfo.compilerName;
    if strcmp(compilerName, 'msvc90') || ...
            strcmp(compilerName, 'msvc80') || ...
            strcmp(compilerName, 'msvc71') || ...
            strcmp(compilerName, 'msvc60'), ...
            compilerName = 'microsoft';
    end
    LibPath = fullfile('$(MATLAB_ROOT)',...
        'extern',...
        'lib',...
        arch,...
        compilerName);
end


%% BLAS Matrix Multiply Operation
% Matrix dimensions are entered as an allowable range of dimensions.
% Format: [Dim1Min Dim2Min ... DimNMin; Dim1Max Dim2Max ... DimNMax]
% Example: [2 2; inf inf] means "any 2D matrix of size 2x2 or larger"
%
%locAddBLASOpEntGemm( hLib,  key,         implName,    out,       outDims,        in1,       in1Dims,        in2,       in2Dims,        alpha,     beta,      LibPath )
locAddBLASOpEntGemm(  hLib, 'RTW_OP_MUL', 'dgemm32',  'double',  [2 2; inf inf], 'double',  [2 2; inf inf], 'double',  [1 1; inf inf], 'double',  'double',   LibPath );
locAddBLASOpEntGemm(  hLib, 'RTW_OP_MUL', 'sgemm32',  'single',  [2 2; inf inf], 'single',  [2 2; inf inf], 'single',  [1 1; inf inf], 'single',  'single',   LibPath );
locAddBLASOpEntGemm(  hLib, 'RTW_OP_MUL', 'zgemm32',  'cdouble', [2 2; inf inf], 'cdouble', [2 2; inf inf], 'cdouble', [1 1; inf inf], 'cdouble', 'cdouble',  LibPath );
locAddBLASOpEntGemm(  hLib, 'RTW_OP_MUL', 'cgemm32',  'csingle', [2 2; inf inf], 'csingle', [2 2; inf inf], 'csingle', [1 1; inf inf], 'csingle', 'csingle',  LibPath );

%locAddBLASOpEntGemm( hLib,  key,         implName,    out,       outDims,        in1,       in1Dims,        in2,       in2Dims,        alpha,     beta,      LibPath )
locAddBLASOpEntGemm(  hLib, 'RTW_OP_TRMUL', 'dgemm32',  'double',  [2 2; inf inf], 'double',  [2 2; inf inf], 'double',  [1 1; inf inf], 'double',  'double',   LibPath );
locAddBLASOpEntGemm(  hLib, 'RTW_OP_TRMUL', 'sgemm32',  'single',  [2 2; inf inf], 'single',  [2 2; inf inf], 'single',  [1 1; inf inf], 'single',  'single',   LibPath );
locAddBLASOpEntGemm(  hLib, 'RTW_OP_TRMUL', 'zgemm32',  'cdouble', [2 2; inf inf], 'cdouble', [2 2; inf inf], 'cdouble', [1 1; inf inf], 'cdouble', 'cdouble',  LibPath );
locAddBLASOpEntGemm(  hLib, 'RTW_OP_TRMUL', 'cgemm32',  'csingle', [2 2; inf inf], 'csingle', [2 2; inf inf], 'csingle', [1 1; inf inf], 'csingle', 'csingle',  LibPath );

%locAddBLASOpEntGemm( hLib,  key,         implName,    out,       outDims,        in1,       in1Dims,        in2,       in2Dims,        alpha,     beta,      LibPath )
locAddBLASOpEntGemm(  hLib, 'RTW_OP_HMMUL', 'zgemm32',  'cdouble', [2 2; inf inf], 'cdouble', [2 2; inf inf], 'cdouble', [1 1; inf inf], 'cdouble', 'cdouble',  LibPath );
locAddBLASOpEntGemm(  hLib, 'RTW_OP_HMMUL', 'cgemm32',  'csingle', [2 2; inf inf], 'csingle', [2 2; inf inf], 'csingle', [1 1; inf inf], 'csingle', 'csingle',  LibPath );

%locAddBLASOpEntGemv( hLib,  key,         implName,    out,       outDims,      in1,       in1Dims,        in2,       in2Dims,      alpha,     beta,      LibPath )
locAddBLASOpEntGemv(  hLib, 'RTW_OP_MUL', 'dgemv32',  'double',  [2 1; inf 1], 'double',  [2 2; inf inf], 'double',  [1 1; inf 1], 'double',  'double',   LibPath );
locAddBLASOpEntGemv(  hLib, 'RTW_OP_MUL', 'sgemv32',  'single',  [2 1; inf 1], 'single',  [2 2; inf inf], 'single',  [1 1; inf 1], 'single',  'single',   LibPath );
locAddBLASOpEntGemv(  hLib, 'RTW_OP_MUL', 'zgemv32',  'cdouble', [2 1; inf 1], 'cdouble', [2 2; inf inf], 'cdouble', [1 1; inf 1], 'cdouble', 'cdouble',  LibPath );
locAddBLASOpEntGemv(  hLib, 'RTW_OP_MUL', 'cgemv32',  'csingle', [2 1; inf 1], 'csingle', [2 2; inf inf], 'csingle', [1 1; inf 1], 'csingle', 'csingle',  LibPath );

%locAddBLASOpEntGemv( hLib,  key,         implName,    out,       outDims,      in1,       in1Dims,        in2,       in2Dims,      alpha,     beta,      LibPath )
locAddBLASOpEntGemv(  hLib, 'RTW_OP_TRMUL', 'dgemv32',  'double',  [2 1; inf 1], 'double',  [2 2; inf inf], 'double',  [1 1; inf 1], 'double',  'double',   LibPath );
locAddBLASOpEntGemv(  hLib, 'RTW_OP_TRMUL', 'sgemv32',  'single',  [2 1; inf 1], 'single',  [2 2; inf inf], 'single',  [1 1; inf 1], 'single',  'single',   LibPath );
locAddBLASOpEntGemv(  hLib, 'RTW_OP_TRMUL', 'zgemv32',  'cdouble', [2 1; inf 1], 'cdouble', [2 2; inf inf], 'cdouble', [1 1; inf 1], 'cdouble', 'cdouble',  LibPath );
locAddBLASOpEntGemv(  hLib, 'RTW_OP_TRMUL', 'cgemv32',  'csingle', [2 1; inf 1], 'csingle', [2 2; inf inf], 'csingle', [1 1; inf 1], 'csingle', 'csingle',  LibPath );

%locAddBLASOpEntGemv( hLib,  key,         implName,    out,       outDims,      in1,       in1Dims,        in2,       in2Dims,      alpha,     beta,      LibPath )
locAddBLASOpEntGemv(  hLib, 'RTW_OP_HMMUL', 'zgemv32',  'cdouble', [2 1; inf 1], 'cdouble', [2 2; inf inf], 'cdouble', [1 1; inf 1], 'cdouble', 'cdouble',  LibPath );
locAddBLASOpEntGemv(  hLib, 'RTW_OP_HMMUL', 'cgemv32',  'csingle', [2 1; inf 1], 'csingle', [2 2; inf inf], 'csingle', [1 1; inf 1], 'csingle', 'csingle',  LibPath );

%% Local Function
function locAddBLASOpEntGemm( hLib, key, implName, out, outDims, in1, in1Dims, in2, in2Dims, alpha, beta, LibPath )
  if isempty(hLib)
    return;
  end
  
  hEnt = RTW.TflBlasEntryGenerator;
  locSetBLASProps( hEnt, key, implName, LibPath );
  locAddGemmArgsToEntry( hLib, hEnt, out, outDims, in1, in1Dims, in2, in2Dims, alpha, beta );
  hLib.addEntry( hEnt );
  
      
%  
function locAddBLASOpEntGemv( hLib, key, implName, out, outDims, in1, in1Dims, in2, in2Dims, alpha, beta, LibPath )
  if isempty(hLib)
    return;
  end
  
  hEnt = RTW.TflBlasEntryGenerator;
  locSetBLASProps( hEnt, key, implName, LibPath );
  locAddGemvArgsToEntry( hLib, hEnt, out, outDims, in1, in1Dims, in2, in2Dims, alpha, beta );
  hLib.addEntry( hEnt );

%
function locSetBLASProps( hEnt, key, implName, LibPath )
  if isempty( hEnt )
    return;
  end
  
  if ispc
      libExt = 'lib';
  elseif ismac
      libExt = 'dylib';
  else
      libExt = 'so';
  end
  
  hEnt.setTflCOperationEntryParameters( ...
      'Key',                         key, ...
      'Priority',                    100, ...
      'ImplementationName',          implName, ...
      'ImplementationHeaderFile',    'blascompat32.h', ...
      'ImplementationHeaderPath',    fullfile('$(MATLAB_ROOT)','extern','include'), ...
      'AdditionalLinkObjs',          {['libmwblascompat32.' libExt]}, ...
      'AdditionalLinkObjsPaths',     {LibPath},...
      'SideEffects',                 true);
%
function locAddGemmArgsToEntry( hLib, hEnt, out, outDims, in1, in1Dims, in2, in2Dims, alpha, beta )
  if isempty(hLib) || isempty( hEnt )
    return;
  end
hEnt.createAndAddConceptualArg('RTW.TflArgMatrix',...
                            'Name',         'y1', ...
                            'IOType',       'RTW_IO_OUTPUT', ...
                            'BaseType',     out, ...
                            'DimRange',     outDims);

hEnt.createAndAddConceptualArg('RTW.TflArgMatrix',...
                            'Name',         'u1', ...
                            'BaseType',     in1, ...
                            'DimRange',     in1Dims);
                        
hEnt.createAndAddConceptualArg('RTW.TflArgMatrix',...
                            'Name',         'u2', ...
                            'BaseType',     in2, ...
                            'DimRange',     in2Dims);
                        
% Using the RTW.TflBlasEntryGenerator for xGEMM requires the following
% implementation signature:
% void f(char* TRANSA, char* TRANSB, int* M, int* N, int* K,
%        type* alpha, type* u1, int* LDA, type* u2, int* LDB,
%        type* beta, type* y, int* LDC)
%
% Upon a successful match, the TFL entry will compute the correct
% values for M, N, K, LDA, LDB, LDC and insert them into the
% generated code. TRANSA and TRANSB will both be set to 'N'.

arg = hLib.getTflArgFromString('y2','void');
arg.IOType = 'RTW_IO_OUTPUT';
hEnt.Implementation.setReturn(arg);

arg = RTW.TflArgCharConstant('TRANSA');
arg.PassByType = 'RTW_PASSBY_POINTER';
hEnt.Implementation.addArgument(arg);

arg = RTW.TflArgCharConstant('TRANSB');
arg.PassByType = 'RTW_PASSBY_POINTER';
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('M','integer', 0);
arg.PassByType = 'RTW_PASSBY_POINTER';
arg.Type.ReadOnly = true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('N','integer', 0);
arg.PassByType = 'RTW_PASSBY_POINTER';
arg.Type.ReadOnly = true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('K','integer', 0);
arg.PassByType = 'RTW_PASSBY_POINTER';
arg.Type.ReadOnly = true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('ALPHA',alpha, 0);
arg.PassByType = 'RTW_PASSBY_POINTER';
arg.Type.ReadOnly = true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('u1',[in1 '*']);
arg.PassByType = 'RTW_PASSBY_POINTER';
arg.Type.ReadOnly = true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('LDA','integer', 0);
arg.PassByType = 'RTW_PASSBY_POINTER';
arg.Type.ReadOnly = true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('u2',[in2 '*']);
arg.PassByType = 'RTW_PASSBY_POINTER';
arg.Type.ReadOnly = true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('LDB','integer', 0);
arg.PassByType = 'RTW_PASSBY_POINTER';
arg.Type.ReadOnly = true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('BETA',beta, 0);
arg.PassByType = 'RTW_PASSBY_POINTER';
arg.Type.ReadOnly = true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('y1',[out '*']);
arg.IOType = 'RTW_IO_OUTPUT';
arg.PassByType = 'RTW_PASSBY_POINTER';
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('LDC','integer', 0);
arg.PassByType = 'RTW_PASSBY_POINTER';
arg.Type.ReadOnly = true;
hEnt.Implementation.addArgument(arg);  

%
function locAddGemvArgsToEntry( hLib, hEnt, out, outDims, in1, in1Dims, in2, in2Dims, alpha, beta )
  if isempty(hLib) || isempty( hEnt )
    return;
  end
hEnt.createAndAddConceptualArg('RTW.TflArgMatrix',...
                            'Name',         'y1', ...
                            'IOType',       'RTW_IO_OUTPUT', ...
                            'BaseType',     out, ...
                            'DimRange',     outDims);

hEnt.createAndAddConceptualArg('RTW.TflArgMatrix',...
                            'Name',         'u1', ...
                            'BaseType',     in1, ...
                            'DimRange',     in1Dims);
                        
hEnt.createAndAddConceptualArg('RTW.TflArgMatrix',...
                            'Name',         'u2', ...
                            'BaseType',     in2, ...
                            'DimRange',     in2Dims);
                        
 
% Using the RTW.TflBlasEntryGenerator for xGEMV requires the following
% implementation signature:
% void f(char* TRANS, int* M, int* N,
%        type* alpha, type* u1, int* LDA, type* u2, int* INCX,
%        type* beta, type* y, int* INCY)
%
% Upon a successful match, the TFL entry will compute the correct
% values for M, N, LDA, INCX, INCY and insert them into the
% generated code. TRANS will be set to 'N'.

arg = hLib.getTflArgFromString('y2','void');
arg.IOType = 'RTW_IO_OUTPUT';
hEnt.Implementation.setReturn(arg);

arg = RTW.TflArgCharConstant('TRANS');
arg.PassByType = 'RTW_PASSBY_POINTER';
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('M','integer', 0);
arg.PassByType = 'RTW_PASSBY_POINTER';
arg.Type.ReadOnly = true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('N','integer', 0);
arg.PassByType = 'RTW_PASSBY_POINTER';
arg.Type.ReadOnly = true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('ALPHA',alpha, 0);
arg.PassByType = 'RTW_PASSBY_POINTER';
arg.Type.ReadOnly = true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('u1',[in1 '*']);
arg.PassByType = 'RTW_PASSBY_POINTER';
arg.Type.ReadOnly = true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('LDA','integer', 0);
arg.PassByType = 'RTW_PASSBY_POINTER';
arg.Type.ReadOnly = true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('u2',[in2 '*']);
arg.PassByType = 'RTW_PASSBY_POINTER';
arg.Type.ReadOnly = true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('INCX','integer', 0);
arg.PassByType = 'RTW_PASSBY_POINTER';
arg.Type.ReadOnly = true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('BETA',beta, 0);
arg.PassByType = 'RTW_PASSBY_POINTER';
arg.Type.ReadOnly = true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('y1',[out '*']);
arg.IOType = 'RTW_IO_OUTPUT';
arg.PassByType = 'RTW_PASSBY_POINTER';
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('INCY','integer', 0);
arg.PassByType = 'RTW_PASSBY_POINTER';
arg.Type.ReadOnly = true;
hEnt.Implementation.addArgument(arg); 
%%
%EOF

