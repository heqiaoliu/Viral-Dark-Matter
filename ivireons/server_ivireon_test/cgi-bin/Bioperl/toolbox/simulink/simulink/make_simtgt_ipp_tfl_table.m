function hLib = make_simtgt_ipp_tfl_table
%MAKE_SIMTGT_TFL
%    
% Non-shipping internal utility for building Target Function Libraries
% Copyright 2003-2009 The MathWorks, Inc.
%
% Create the Simulation Targets instance of the UDD Target specific math library
%
%   
% $Revision: 1.1.8.1 $
% $Date: 2009/10/24 19:36:01 $

hLib = RTW.TflTable;

%% the IPP TFL entries 
SrcCodePath = fullfile('$(MATLAB_ROOT)','toolbox','shared', 'ipp', 'src');
IncludeCodePath = fullfile('$(MATLAB_ROOT)','toolbox','shared', 'ipp', 'include');

addFir2dEntry(hLib, 'mw_ipp_conv2d_single', 'single', 'RTW_FIR2D_CONV_MODE', SrcCodePath, IncludeCodePath);
addFir2dEntry(hLib, 'mw_ipp_conv2d_double', 'double', 'RTW_FIR2D_CONV_MODE', SrcCodePath, IncludeCodePath);
addFir2dEntry(hLib, 'mw_ipp_corr2d_single', 'single', 'RTW_FIR2D_CORR_MODE', SrcCodePath, IncludeCodePath);
addFir2dEntry(hLib, 'mw_ipp_corr2d_double', 'double', 'RTW_FIR2D_CORR_MODE', SrcCodePath, IncludeCodePath);

% -------------------------------------------------------------------------
function addFir2dEntry(hLib, implname, datatype, convcorrmode, ...
            SrcCodePath, IncludeCodePath)

arch = lower(computer);
if isequal(arch, 'pcwin')
    arch = 'win32';
elseif isequal(arch, 'pcwin64')
    arch = 'win64';
end

ArchIncludeCodePath = fullfile(IncludeCodePath, arch);

e = RTW.TflCFunctionEntryTypeCheck4Fir2d;
e.setTflCFunctionEntryParameters(...
    'Key',                         'Fir2d', ...
    'Priority',                    100, ...
    'ImplementationName',          implname, ...
    'ImplementationHeaderFile',    'mw_ipp.h', ...
    'ImplementationSourceFile',    'mw_ipp.c', ...
    'ImplementationHeaderPath',    IncludeCodePath, ...
    'ImplementationSourcePath',    SrcCodePath, ...
    'SideEffects',                 true, ...
    'SaturationMode',              'RTW_SATURATE_UNSPECIFIED', ...
    'RoundingMode',                'RTW_ROUND_UNSPECIFIED', ...
    'ConvCorrMode',                convcorrmode, ...
    'OutputMode',                  'RTW_FIR2D_OUTPUT_UNSPECIFIED', ...
    'GenCallback',                 'RTW.copyFileToBuildDir', ...
    'AdditionalIncludePaths',      {ArchIncludeCodePath});
%return
e.createAndAddConceptualArg('RTW.TflArgVoid',...
    'Name',           'y1',...
    'IOType',         'RTW_IO_OUTPUT');
%u
e.createAndAddConceptualArg('RTW.TflArgNumeric',...
    'Name',           'u1',...
    'DataTypeMode', datatype );
%y
e.createAndAddConceptualArg('RTW.TflArgNumeric',...
    'Name',           'u3',...
    'DataTypeMode', datatype );
%h
e.createAndAddConceptualArg('RTW.TflArgNumeric',...
    'Name',           'u2',...
    'DataTypeMode', datatype );

%acc type
e.createAndAddConceptualArg('RTW.TflArgNumeric',...
    'Name',           'u4',...
    'DataTypeMode', datatype );

%product type
e.createAndAddConceptualArg('RTW.TflArgNumeric',...
    'Name',           'u5',...
    'DataTypeMode', datatype );

%mask row
arg = hLib.getTflArgFromString('u6', 'int32');
e.addConceptualArg(arg);

%mask col
arg = hLib.getTflArgFromString('u7', 'int32');
e.addConceptualArg(arg);

%in row
arg = hLib.getTflArgFromString('u8', 'int32');
e.addConceptualArg(arg);

%in col
arg = hLib.getTflArgFromString('u9', 'int32');
e.addConceptualArg(arg);

%out row
arg = hLib.getTflArgFromString('u10', 'int32');
e.addConceptualArg(arg);

%out col
arg = hLib.getTflArgFromString('u11', 'int32');
e.addConceptualArg(arg);

%conv corr mode
arg = hLib.getTflArgFromString('u12', 'int32');
e.addConceptualArg(arg);

%out mode
arg = hLib.getTflArgFromString('u13', 'int32');
e.addConceptualArg(arg);

%rounding mode
arg = hLib.getTflArgFromString('u14', 'int32');
e.addConceptualArg(arg);

%overflow mode
arg = hLib.getTflArgFromString('u15', 'int32');
e.addConceptualArg(arg);

%hDims
arg = hLib.getTflArgFromString('u16', 'int32');
e.addConceptualArg(arg);

%hCenter
arg = hLib.getTflArgFromString('u17', 'int32');
e.addConceptualArg(arg);

%UDims
arg = hLib.getTflArgFromString('u18', 'int32');
e.addConceptualArg(arg);

%UOrigin
arg = hLib.getTflArgFromString('u19', 'int32');
e.addConceptualArg(arg);

%YDims
arg = hLib.getTflArgFromString('u20', 'int32');
e.addConceptualArg(arg);

%YOrign
arg = hLib.getTflArgFromString('u21', 'int32');
e.addConceptualArg(arg);

%YInSStart
arg = hLib.getTflArgFromString('u22', 'int32');
e.addConceptualArg(arg);

%YInSEnd
arg = hLib.getTflArgFromString('u23', 'int32');
e.addConceptualArg(arg);

arg = hLib.getTflArgFromString('y1','void');
e.Implementation.setReturn(arg);

arg = hLib.getTflArgFromString('u1',[datatype '*']);
e.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('u2',[datatype '*']);
e.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('u3',[datatype '*']);
e.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('u16','int32*');
e.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('u17','int32*');
e.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('u18','int32*');
e.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('u19','int32*');
e.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('u20','int32*');
e.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('u21','int32*');
e.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('u22','int32*');
e.Implementation.addArgument(arg);

arg = hLib.getTflArgFromString('u23','int32*');
e.Implementation.addArgument(arg);

hLib.addEntry( e );


% EOF

