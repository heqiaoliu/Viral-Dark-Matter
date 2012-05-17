%% Start and Terminate Actions within Legacy Functions
% This demo shows you how to use the Legacy Code Tool to integrate legacy C 
% functions that have start and terminate actions.
% 
% The Legacy Code Tool allows you to:
%
% * Provide the legacy function specification,
% * Generate a C-MEX S-function that is used during simulation to call the legacy code, and
% * Compile and build the generated S-function for simulation.
%

%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/11/13 05:06:22 $

%% Providing the Legacy Function Specification
% All functions provided with the Legacy Code Tool take a specific data 
% structure or array of structures as the argument. The data structure is 
% initialized by calling the function legacy_code() using the 'initialize'
% first input. After initializing the structure, you have to assign its
% properties to values corresponding to the legacy code being integrated.  
% For detailed help on the properties, call 
% <matlab:legacy_code('help') legacy_code('help')>. The 
% prototypes of the legacy functions being called in this demo are:
%
% * void initFaultCounter(unsigned int *counter)
% * void openLogFile(void **fid)
% * void incAndLogFaultCounter(void *fid, unsigned int *counter, double time)
% * void closeLogFile(void **fid)
%
% The legacy source code is found in the files
% <matlab:sldemo_lct_util('edit','sldemo_lct_src/your_types.h') your_types.h>,
% <matlab:sldemo_lct_util('edit','sldemo_lct_src/fault.h') fault.h>, and
% <matlab:sldemo_lct_util('edit','sldemo_lct_src/fault.c') fault.c>.

% sldemo_sfun_fault
def = legacy_code('initialize');
def.SFunctionName                = 'sldemo_sfun_fault';
def.InitializeConditionsFcnSpec  = 'initFaultCounter(uint32 work2[1])';
def.StartFcnSpec                 = 'openLogFile(void **work1)';
def.OutputFcnSpec                = 'incAndLogFaultCounter(void *work1, uint32 work2[1], double u1)';
def.TerminateFcnSpec             = 'closeLogFile(void **work1)';
def.HeaderFiles                  = {'fault.h'};
def.SourceFiles                  = {'fault.c'};
def.IncPaths                     = {'sldemo_lct_src'}; 
def.SrcPaths                     = {'sldemo_lct_src'}; 
def.Options.useTlcWithAccel      = false;

%% Generating and compiling an S-Function for Use During Simulation
% The function legacy_code() is called again with the first input set to 
% 'generate_for_sim' in order to automatically generate and compile the C-MEX 
% S-function according to the description provided by the input argument 
% 'def'.  This S-function is used to call the legacy functions in simulation.
% The source code for the S-function is found in the file
% <matlab:sldemo_lct_util('edit','sldemo_sfun_fault.c') sldemo_sfun_fault.c>.

legacy_code('generate_for_sim', def);

%% Generating an rtwmakecfg.m File for Code Generation
% After the TLC block file is created, the function
% legacy_code() can be called again with the first input set to 
% 'rtwmakecfg_generate' in order to generate an rtwmakecfg.m file to support
% code generation through Real Time Workshop. The file is needed only if 
% the required source and header files for the S-functions are not in the 
% same directory as the S-functions, and you want to add these 
% dependencies in the makefile produced during code generation.
%
% Note: This step is only needed if you simulate the model in accelerated mode.

legacy_code('rtwmakecfg_generate', def);

%% Generating a masked S-Function block for calling the generated S-Function
% After the C-MEX S-function source is compiled, the function 
% legacy_code() can be called again with the first input set to 'slblock_generate' in order
% to generate a masked S-function block that is configured to call that
% S-function.  The block is placed in a new model and can be copied to an
% existing model.

% legacy_code('slblock_generate', def);

%% Demoing the Generated Integration with Legacy Code
% The model <matlab:sldemo_lct_start_term sldemo_lct_start_term> 
% shows integration with the legacy
% code.  The subsystem TestFixpt serves as a harness for the call to the
% legacy C function, and the scope compares the output of the function with
% the output of the built-in Simulink(R) product block; the results should be
% identical.

open_system('sldemo_lct_start_term')
open_system('sldemo_lct_start_term/TestFault')
sim('sldemo_lct_start_term')




displayEndOfDemoMessage(mfilename)
