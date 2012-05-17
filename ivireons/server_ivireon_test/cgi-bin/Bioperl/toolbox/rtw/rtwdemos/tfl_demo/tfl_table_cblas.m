function hLib = tfl_table_cblas
% Copyright 2008-2009 The MathWorks, Inc.

% $Revision $
% $Date: 2009/11/13 04:57:14 $

hLib = RTW.TflTable;

LibPath = fullfile(matlabroot,...
                   'toolbox',...
                   'rtw',...
                   'rtwdemos',...
                   'tfl_demo');

%% BLAS Matrix Multiply Operation
% Matrix dimensions are entered as an allowable range of dimensions.
% Format: [Dim1Min Dim2Min ... DimNMin; Dim1Max Dim2Max ... DimNMax]
% Example: [2 2; inf inf] means "any 2D matrix of size 2x2 or larger"
%
%locAddBLASOpEntGemm( hLib,  key,          implName,        out,      outDims,          in1,       in1Dims,          in2,       in2Dims,          alpha,     beta,       LibPath )
locAddCBLASOpEntGemm(  hLib, 'RTW_OP_MUL', 'cblas_dgemm',  'double',  [2 2; inf inf],   'double',  [2 2; inf inf],   'double',  [1 1; inf inf],   'double',  'double',   LibPath );
locAddCBLASOpEntGemm(  hLib, 'RTW_OP_MUL', 'cblas_sgemm',  'single',  [2 2; inf inf],   'single',  [2 2; inf inf],   'single',  [1 1; inf inf],   'single',  'single',   LibPath );
locAddCBLASOpEntGemm(  hLib, 'RTW_OP_MUL', 'cblas_zgemm',  'cdouble', [2 2; inf inf],   'cdouble', [2 2; inf inf],   'cdouble', [1 1; inf inf],   'cdouble', 'cdouble',  LibPath );
locAddCBLASOpEntGemm(  hLib, 'RTW_OP_MUL', 'cblas_cgemm',  'csingle', [2 2; inf inf],   'csingle', [2 2; inf inf],   'csingle', [1 1; inf inf],   'csingle', 'csingle',  LibPath );

%locAddBLASOpEntGemm( hLib,  key,          implName,        out,      outDims,          in1,       in1Dims,          in2,       in2Dims,          alpha,     beta,       LibPath )
locAddCBLASOpEntGemm(  hLib, 'RTW_OP_HMMUL', 'cblas_zgemm',  'cdouble', [2 2; inf inf],   'cdouble', [2 2; inf inf],   'cdouble', [1 1; inf inf],   'cdouble', 'cdouble',  LibPath );
locAddCBLASOpEntGemm(  hLib, 'RTW_OP_HMMUL', 'cblas_cgemm',  'csingle', [2 2; inf inf],   'csingle', [2 2; inf inf],   'csingle', [1 1; inf inf],   'csingle', 'csingle',  LibPath );

%locAddBLASOpEntGemm( hLib,  key,          implName,        out,      outDims,          in1,       in1Dims,          in2,       in2Dims,          alpha,     beta,       LibPath )
locAddCBLASOpEntGemm(  hLib, 'RTW_OP_TRMUL', 'cblas_dgemm',  'double',  [2 2; inf inf],   'double',  [2 2; inf inf],   'double',  [1 1; inf inf],   'double',  'double',   LibPath );
locAddCBLASOpEntGemm(  hLib, 'RTW_OP_TRMUL', 'cblas_sgemm',  'single',  [2 2; inf inf],   'single',  [2 2; inf inf],   'single',  [1 1; inf inf],   'single',  'single',   LibPath );
locAddCBLASOpEntGemm(  hLib, 'RTW_OP_TRMUL', 'cblas_zgemm',  'cdouble', [2 2; inf inf],   'cdouble', [2 2; inf inf],   'cdouble', [1 1; inf inf],   'cdouble', 'cdouble',  LibPath );
locAddCBLASOpEntGemm(  hLib, 'RTW_OP_TRMUL', 'cblas_cgemm',  'csingle', [2 2; inf inf],   'csingle', [2 2; inf inf],   'csingle', [1 1; inf inf],   'csingle', 'csingle',  LibPath );

%locAddBLASOpEntGemv( hLib,  key,          implName,        out,       outDims,     in1,       in1Dims,        in2,       in2Dims,        alpha,     beta,       LibPath )
locAddCBLASOpEntGemv(  hLib, 'RTW_OP_MUL', 'cblas_dgemv',  'double',  [2 1; inf 1], 'double',  [2 2; inf inf], 'double',  [1 1; inf inf], 'double',  'double',   LibPath );
locAddCBLASOpEntGemv(  hLib, 'RTW_OP_MUL', 'cblas_sgemv',  'single',  [2 1; inf 1], 'single',  [2 2; inf inf], 'single',  [1 1; inf inf], 'single',  'single',   LibPath );
locAddCBLASOpEntGemv(  hLib, 'RTW_OP_MUL', 'cblas_zgemv',  'cdouble', [2 1; inf 1], 'cdouble', [2 2; inf inf], 'cdouble', [1 1; inf inf], 'cdouble', 'cdouble',  LibPath );
locAddCBLASOpEntGemv(  hLib, 'RTW_OP_MUL', 'cblas_cgemv',  'csingle', [2 1; inf 1], 'csingle', [2 2; inf inf], 'csingle', [1 1; inf inf], 'csingle', 'csingle',  LibPath );

%locAddBLASOpEntGemv( hLib,  key,          implName,        out,       outDims,     in1,       in1Dims,        in2,       in2Dims,        alpha,     beta,       LibPath )
locAddCBLASOpEntGemv(  hLib, 'RTW_OP_HMMUL', 'cblas_zgemv',  'cdouble', [2 1; inf 1], 'cdouble', [2 2; inf inf], 'cdouble', [1 1; inf inf], 'cdouble', 'cdouble',  LibPath );
locAddCBLASOpEntGemv(  hLib, 'RTW_OP_HMMUL', 'cblas_cgemv',  'csingle', [2 1; inf 1], 'csingle', [2 2; inf inf], 'csingle', [1 1; inf inf], 'csingle', 'csingle',  LibPath );

%locAddBLASOpEntGemv( hLib,  key,          implName,        out,       outDims,     in1,       in1Dims,        in2,       in2Dims,        alpha,     beta,       LibPath )
locAddCBLASOpEntGemv(  hLib, 'RTW_OP_TRMUL', 'cblas_dgemv',  'double',  [2 1; inf 1], 'double',  [2 2; inf inf], 'double',  [1 1; inf inf], 'double',  'double',   LibPath );
locAddCBLASOpEntGemv(  hLib, 'RTW_OP_TRMUL', 'cblas_sgemv',  'single',  [2 1; inf 1], 'single',  [2 2; inf inf], 'single',  [1 1; inf inf], 'single',  'single',   LibPath );
locAddCBLASOpEntGemv(  hLib, 'RTW_OP_TRMUL', 'cblas_zgemv',  'cdouble', [2 1; inf 1], 'cdouble', [2 2; inf inf], 'cdouble', [1 1; inf inf], 'cdouble', 'cdouble',  LibPath );
locAddCBLASOpEntGemv(  hLib, 'RTW_OP_TRMUL', 'cblas_cgemv',  'csingle', [2 1; inf 1], 'csingle', [2 2; inf inf], 'csingle', [1 1; inf inf], 'csingle', 'csingle',  LibPath );
%% Local Function
 
function locAddCBLASOpEntGemm( hLib, key, implName, out, outDims, in1, in1Dims, in2, in2Dims, alpha, beta, LibPath )
  if isempty(hLib)
    return;
  end
  
  hEnt = RTW.TflCBlasEntryGenerator;
  locSetBLASProps( hEnt, key, implName, LibPath );
  locAddGemmArgsToEntry( hLib, hEnt, out, outDims, in1, in1Dims, in2, in2Dims, alpha, beta );
  hLib.addEntry( hEnt );
  
      
%  
function locAddCBLASOpEntGemv( hLib, key, implName, out, outDims, in1, in1Dims, in2, in2Dims, alpha, beta, LibPath )
  if isempty(hLib)
    return;
  end
  
  hEnt = RTW.TflCBlasEntryGenerator;
  locSetBLASProps( hEnt, key, implName, LibPath );
  locAddGemvArgsToEntry( hLib, hEnt, out, outDims, in1, in1Dims, in2, in2Dims, alpha, beta );
  hLib.addEntry( hEnt );

%
function locSetBLASProps( hEnt, key, implName, LibPath ) 
  if isempty( hEnt )
    return;
  end
  
  hEnt.setTflCOperationEntryParameters( ...
      'Key',                         key, ...
      'Priority',                    100, ...
      'ImplementationName',          implName, ...
      'ImplementationHeaderFile',    'cblas.h', ...
      'ImplementationHeaderPath', LibPath, ...
      'AdditionalIncludePaths',   {LibPath}, ...
      'GenCallback',              'RTW.copyFileToBuildDir', ...
      'SideEffects',                 true);
  
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
                        
 
% Using the RTW.TflCBlasEntryGenerator for xGEMM requires the following
% implementation signature:
% void f(enum Order, enum TRANSA, enum TRANSB, int M, int N, int K,
%        type alpha, type* u1, int LDA, type* u2, int LDB,
%        type beta, type* y, int LDC)
% Since the TFL does not have the ability to specify enums, we must
% use integer. This will cause problems with C++ code generation, so
% for C++, a wrapper function must be introduced to cast the int
% to the appropriate enumeration type.
%
% Upon a successful match, the TFL entry will compute the correct
% values for M, N, K, LDA, LDB, LDC and insert them into the
% generated code.
arg = hLib.getTflArgFromString('y2','void');
arg.IOType = 'RTW_IO_OUTPUT';
hEnt.Implementation.setReturn(arg);

arg = hLib.getTflArgFromString('ORDER','integer', 102);
%arg.Type.ReadOnly=true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('TRANSA','integer', 111);
%arg.Type.ReadOnly=true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('TRANSB','integer', 111);
%arg.Type.ReadOnly=true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('M','integer', 0);
%arg.Type.ReadOnly=true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('N','integer', 0);
%arg.Type.ReadOnly=true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('K','integer', 0);
%arg.Type.ReadOnly=true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('ALPHA',alpha, 1);
if strcmp(alpha,'csingle') || strcmp(alpha,'cdouble')
    arg.PassByType = 'RTW_PASSBY_VOID_POINTER';
end
%arg.Type.ReadOnly=true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('u1',[in1 '*']);
if strcmp(in1,'csingle') || strcmp(in1,'cdouble')
    arg.PassByType = 'RTW_PASSBY_VOID_POINTER';
end
%arg.Type.ReadOnly=true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('LDA','integer', 0);
%arg.Type.ReadOnly=true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('u2',[in2 '*']);
if strcmp(in2,'csingle') || strcmp(in2,'cdouble')
    arg.PassByType = 'RTW_PASSBY_VOID_POINTER';
end
%arg.Type.ReadOnly=true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('LDB','integer', 0);
%arg.Type.ReadOnly=true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('BETA',beta, 0);
if strcmp(beta,'csingle') || strcmp(beta,'cdouble')
    arg.PassByType = 'RTW_PASSBY_VOID_POINTER';
end
%arg.Type.ReadOnly=true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('y1',[out '*']);
arg.IOType = 'RTW_IO_OUTPUT';
if strcmp(out,'csingle') || strcmp(out,'cdouble')
    arg.PassByType = 'RTW_PASSBY_VOID_POINTER';
end
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('LDC','integer', 0);
%arg.Type.ReadOnly=true;
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
                        
 
% Using the RTW.TflCBlasEntryGenerator for xGEMV requires the following
% implementation signature:
% void f(enum Order, enum TRANSA, int M, int N,
%        type alpha, type* u1, int LDA, type* u2, int INCX,
%        type beta, type* y, int INCY)
% Since the TFL does not have the ability to specify enums, we must
% use integer. This will cause problems with C++ code generation, so
% for C++, a wrapper function must be introduced to cast the int
% to the appropriate enumeration type.
%
% Upon a successful match, the TFL entry will compute the correct
% values for M, N, LDA, INCX, INCY and insert them into the
% generated code.
arg = hLib.getTflArgFromString('y2','void');
arg.IOType = 'RTW_IO_OUTPUT';
hEnt.Implementation.setReturn(arg);

arg = hLib.getTflArgFromString('ORDER','integer', 102);
%arg.Type.ReadOnly=true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('TRANSA','integer', 111);
%arg.Type.ReadOnly=true;
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('M','integer', 0);
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('N','integer', 0);
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('ALPHA',alpha, 1);
if strcmp(alpha,'csingle') || strcmp(alpha,'cdouble')
    arg.PassByType = 'RTW_PASSBY_VOID_POINTER';
end
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('u1',[in1 '*']);
if strcmp(in1,'csingle') || strcmp(in1,'cdouble')
    arg.PassByType = 'RTW_PASSBY_VOID_POINTER';
end
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('LDA','integer', 0);
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('u2',[in2 '*']);
if strcmp(in2,'csingle') || strcmp(in2,'cdouble')
    arg.PassByType = 'RTW_PASSBY_VOID_POINTER';
end
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('INCX','integer', 0);
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('BETA',beta, 0);
if strcmp(beta,'csingle') || strcmp(beta,'cdouble')
    arg.PassByType = 'RTW_PASSBY_VOID_POINTER';
end
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('y1',[out '*']);
arg.IOType = 'RTW_IO_OUTPUT';
if strcmp(out,'csingle') || strcmp(out,'cdouble')
    arg.PassByType = 'RTW_PASSBY_VOID_POINTER';
end
hEnt.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('INCY','integer', 0);
hEnt.Implementation.addArgument(arg); 
%%
%EOF

