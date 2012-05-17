function schema
% SCHEMA - define RTW.makertw class structure

%   Copyright 2002-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.17 $  $Date: 2010/04/05 22:29:35 $


%%%% Get handles of associated packages and classes
% Not derived from any other class
hCreateInPackage   = findpackage('RTW');
%%%% Construct class
hThisClass = schema.class(hCreateInPackage, 'makertw');

%%%% Add properties to this class
%% Following properties are initialized at ParseBuildArgs() method
hThisProp = schema.prop(hThisClass, 'ModelName', 'string');
% needs be double to correct store handle value
hThisProp = schema.prop(hThisClass, 'ModelHandle', 'double');
hThisProp = schema.prop(hThisClass, 'InitRTWOptsAndGenSettingsOnly', 'double');
hThisProp = schema.prop(hThisClass, 'BuildArgs', 'string');
hThisProp = schema.prop(hThisClass, 'DispHook', 'MATLAB array');
hThisProp = schema.prop(hThisClass, 'MdlRefBuildArgs', 'MATLAB array');
% ADA support has been removed, so languageDir is fixed to 'c'
%hThisProp = schema.prop(hThisClass, 'languageDir', 'string');
%hThisProp = schema.prop(hThisClass, 'adaEnvVar', 'string');

%%%% Add properties to this class
%% Following properties are initialized at CacheOriginalData() method
hThisProp = schema.prop(hThisClass, 'OrigRecycleState', 'string');

%% Following properties are initialized at PrepareAcceleratorAndSFunction() method
hThisProp = schema.prop(hThisClass, 'CodeReuse', 'double');

%% Following properties are initialized at GetSystemTargetFile() method
hThisProp = schema.prop(hThisClass, 'SystemTargetFilename', 'string');
hThisProp = schema.prop(hThisClass, 'MakeRTWHookMFile', 'string');

%% Following properties are initialized at PrepareBuildArgs() method
hThisProp = schema.prop(hThisClass, 'BuildDirectory', 'string');
hThisProp = schema.prop(hThisClass, 'StartDirToRestore', 'string');
hThisProp = schema.prop(hThisClass, 'GeneratedTLCSubDir', 'string');
    %% Following properties are initialized at LocGetTMF() method
hThisProp = schema.prop(hThisClass, 'TemplateMakefile', 'string');
hThisProp = schema.prop(hThisClass, 'CompilerEnvVal', 'string');
    %% Following properties are initialized at getrtwroot() method
hThisProp = schema.prop(hThisClass, 'RTWRoot', 'string');

%% Following properties are initialized at CreateBuildOpts() method
hThisProp = schema.prop(hThisClass, 'BuildOpts', 'MATLAB array');

%% Certain compilers need additional info out of the mexopts.bat file, this
% property is used to pass it along
hThisProp = schema.prop(hThisClass, 'mexOpts', 'MATLAB array');

%% The control the file created for build log purpose
hThisProp = schema.prop(hThisClass, 'LogFileName', 'string');

%% This property holds all of the build information, which can be modified by
%the user via the make_rtw_hook method.
hThisProp = schema.prop(hThisClass, 'BuildInfo', 'handle');
hThisProp.FactoryValue = [];
hThisProp = schema.prop(hThisClass, 'ProjectBuild', 'bool');
hThisProp.FactoryValue = false;
%% Storing changes that happen in build process and should not affect model
%% dirty bit
hThisProp = schema.prop(hThisClass, 'ChangeRec', 'MATLAB array');
hThisProp.FactoryValue = [];

% the pwd is temporarily added to the path during the build.  this is used to
% store the original path, so that it can be restored.
hThisProp = schema.prop(hThisClass, 'PathToRestore', 'string');
hThisProp.FactoryValue = '';

% store the compiler name 
hThisProp = schema.prop(hThisClass, 'CompilerName', 'string');
hThisProp.FactoryValue = '';

% store the prefdir mexopts.bat (pr ENVVAR) points to which compiler
hThisProp = schema.prop(hThisClass, 'PreferredTMF', 'string');
hThisProp.FactoryValue = '';

% store the install dir mexopts.bat name
hThisProp = schema.prop(hThisClass, 'InstallDirmexopts', 'string');
hThisProp.FactoryValue = '';

% LocalWords:  ada Env TMF getrtwroot mexopts ENVVAR Dirmexopts
