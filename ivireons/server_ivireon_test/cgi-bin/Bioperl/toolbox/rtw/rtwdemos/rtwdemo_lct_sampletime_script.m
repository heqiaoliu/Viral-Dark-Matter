%% Specification of Block Sample Time
% This demo shows you how to use the Legacy Code Tool to integrate legacy C 
% functions with the block's sample time specified, inherited and 
% parameterized.
%
% The Legacy Code Tool allows you to:
%
% * Provide the legacy function specification,
% * Generate a C-MEX S-function that is used during simulation to call the legacy code, and
% * Generate a block TLC file and optional rtwmakecfg.m file that is used during code generation to call the legacy code.
%

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2008/12/01 07:30:56 $

%% Providing the Legacy Function Specification
% All functions provided with the Legacy Code Tool take a specific data 
% structure or array of structures as the argument. The data structure is 
% initialized by calling the function legacy_code() using 'initialize' as the
% first input. After initializing the structure, you have to assign its
% properties to values corresponding to the legacy code being integrated.  
% For detailed help on the properties, call 
% <matlab:legacy_code('help') legacy_code('help')>. The 
% prototypes of the legacy functions being called in this demo are:
%
% FLT gainScalar(const FLT in, const FLT gain)
%
% where FLT is a typedef to float.  The legacy source code is found in the
% files
% <matlab:sldemo_lct_util('edit','sldemo_lct_src/your_types.h') your_types.h>, 
% <matlab:sldemo_lct_util('edit','sldemo_lct_src/gain.h') gain.h>, and
% <matlab:sldemo_lct_util('edit','sldemo_lct_src/gainScalar.c') gainScalar.c>.

defs = [];

% rtwdemo_sfun_st_inherited
def = legacy_code('initialize');
def.SFunctionName = 'rtwdemo_sfun_st_inherited';
def.OutputFcnSpec = 'single y1 = gainScalar(single u1, single p1)';
def.HeaderFiles   = {'gain.h'};
def.SourceFiles   = {'gainScalar.c'};
def.IncPaths      = {'sldemo_lct_src'}; 
def.SrcPaths      = {'sldemo_lct_src'}; 
defs = [defs; def];

% rtwdemo_sfun_st_fixed
def = legacy_code('initialize');
def.SFunctionName = 'rtwdemo_sfun_st_fixed';
def.OutputFcnSpec = 'single y1 = gainScalar(single u1, single p1)';
def.HeaderFiles   = {'gain.h'};
def.SourceFiles   = {'gainScalar.c'};
def.IncPaths      = {'sldemo_lct_src'}; 
def.SrcPaths      = {'sldemo_lct_src'}; 
def.SampleTime    = [2 1];
defs = [defs; def];

% rtwdemo_sfun_st_parameterized
def = legacy_code('initialize');
def.SFunctionName = 'rtwdemo_sfun_st_parameterized';
def.OutputFcnSpec = 'single y1 = gainScalar(single u1, single p1)';
def.HeaderFiles   = {'gain.h'};
def.SourceFiles   = {'gainScalar.c'};
def.IncPaths      = {'sldemo_lct_src'}; 
def.SrcPaths      = {'sldemo_lct_src'}; 
def.SampleTime    = 'parameterized';
defs = [defs; def];

%% Generating S-Functions for Use During Simulation
% The function legacy_code() is called again with the first input set to 
% 'sfcn_cmex_generate' in order to automatically generate C-MEX S-functions
% according to the description provided by the input argument 'defs'.
% The S-functions are used to call the legacy functions in simulation.
% The source code for the S-functions is found in the files
% <matlab:rtwdemo_lct_util('edit','rtwdemo_sfun_st_inherited.c') rtwdemo_sfun_st_inherited.c> and
% <matlab:rtwdemo_lct_util('edit','rtwdemo_sfun_st_fixed.c') rtwdemo_sfun_st_fixed.c>.
% <matlab:rtwdemo_lct_util('edit','rtwdemo_sfun_st_parameterized.c') rtwdemo_sfun_st_parameterized.c>.

legacy_code('sfcn_cmex_generate', defs);

%% Compiling the Generated S-Function for Simulation
% After the C-MEX S-function source files are generated, the function 
% legacy_code() is called again with the first input set to 'compile' in order
% to compile the S-function for simulation with Simulink(R).

legacy_code('compile', defs);

%% Generating a TLC Block File for Code Generation
% After the S-function is compiled and used in simulation, the function
% legacy_code() can be called again with the first input set to 
% 'sfcn_tlc_generate' in order to generate a TLC block file to support
% code generation through Real Time Workshop. Code generation will fail 
% if the TLC block file is not created and you try to generate code for a model
% that includes the S-function. The TLC block file for the S-function is:
% <matlab:rtwdemo_lct_util('edit','rtwdemo_sfun_st_inherited.tlc') rtwdemo_sfun_st_inherited.tlc> and
% <matlab:rtwdemo_lct_util('edit','rtwdemo_sfun_st_fixed.tlc') rtwdemo_sfun_st_fixed.tlc>.
% <matlab:rtwdemo_lct_util('edit','rtwdemo_sfun_st_parameterized.tlc') rtwdemo_sfun_st_parameterized.tlc>.

legacy_code('sfcn_tlc_generate', defs);

%% Generating an rtwmakecfg.m File for Code Generation
% After the TLC block file is created, the function
% legacy_code() can be called again with the first input set to 
% 'rtwmakecfg_generate' in order to generate an rtwmakecfg.m file to support
% code generation through Real Time Workshop. The file is needed only if 
% the required source and header files for the S-functions are not in the 
% same directory as the S-functions, and you want to add these 
% dependencies in the makefile produced during code generation.

legacy_code('rtwmakecfg_generate', defs);

%% Generating a masked S-Function block for calling the generated S-Function
% After the C-MEX S-function source is compiled, the function 
% legacy_code() can be called again with the first input set to 'slblock_generate' in order
% to generate a masked S-function block that is configured to call that
% S-function.  The block is placed in a new model and can be copied to an
% existing model.

% legacy_code('slblock_generate', defs);

%% Demoing the Generated Integration with Legacy Code
% The model <matlab:rtwdemo_lct_sampletime rtwdemo_lct_sampletime> 
% shows integration with the legacy
% code. The subsystem sample_time serves as a harness for the calls to the
% legacy C functions, with unit delays serving to store the previous 
% output values.

open_system('rtwdemo_lct_sampletime')
open_system('rtwdemo_lct_sampletime/sample_time')
sim('rtwdemo_lct_sampletime')

displayEndOfDemoMessage(mfilename)
