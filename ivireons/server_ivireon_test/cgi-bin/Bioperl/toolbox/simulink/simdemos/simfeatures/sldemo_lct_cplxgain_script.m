%% Complex Signals in Legacy Function
% This demo shows you how to use the Legacy Code Tool to integrate legacy C 
% functions using complex signals.
%
% The Legacy Code Tool allows you to:
%
% * Provide the legacy function specification,
% * Generate a C-MEX S-function that is used during simulation to call the legacy code, and
% * Compile and build the generated S-function for simulation.
%

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/11/13 05:06:12 $

%% Providing the Legacy Function Specification
% All functions provided with the Legacy Code Tool take a specific data 
% structure or array of structures as the argument. The data structure is 
% initialized by calling the function legacy_code() using 'initialize' as the
% first input. After initializing the structure, you have to assign its
% properties to values corresponding to the legacy code being integrated.  
% For detailed help on the properties, call 
% <matlab:legacy_code('help') legacy_code('help')>. The 
% prototype of the legacy functions being called in this demo is:
%
% void cplx_gain(creal_T *input, creal_T *gain, creal_T *output);
%
% where creal_T is the complex representation of a double.  The legacy source code is found in the
% files
% <matlab:sldemo_lct_util('edit','sldemo_lct_src/cplxgain.h') cplxgain.h>, and
% <matlab:sldemo_lct_util('edit','sldemo_lct_src/cplxgain.c') cplxgain.c>.

% sldemo_sfun_gain_scalar
def = legacy_code('initialize');
def.SFunctionName = 'sldemo_sfun_cplx_gain';
def.OutputFcnSpec = 'void cplx_gain(complex<double> u1[1], complex<double> p1[1], complex<double> y1[1])';
def.HeaderFiles   = {'cplxgain.h'};
def.SourceFiles   = {'cplxgain.c'};
def.IncPaths      = {'sldemo_lct_src'}; 
def.SrcPaths      = {'sldemo_lct_src'}; 

%% Generating and compiling an S-Function for Use During Simulation
% The function legacy_code() is called again with the first input set to 
% 'generate_for_sim' in order to automatically generate and compile the C-MEX 
% S-function according to the description provided by the input argument 
% 'def'.  This S-function is used to call the legacy functions in simulation.
% The source code for the S-function is found in the file
% <matlab:sldemo_lct_util('edit','sldemo_sfun_cplx_gain.c') sldemo_sfun_cplx_gain.c>.

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
% legacy_code() can be called again with the first input set to 'slblock_generate'
% in order to generate a masked S-function block that is configured to call that
% S-function.  The block is placed in a new model and can be copied to an
% existing model.

% legacy_code('slblock_generate', def);

%% Demoing the Generated Integration with Legacy Code
% The model <matlab:sldemo_lct_cplxgain sldemo_lct_cplxgain> 
% shows integration with the legacy
% code.  The subsystem complex_gain serves as a harness for the call to the
% legacy C function via the generate S-function.

if isempty(find_system('SearchDepth',0,'Name','sldemo_lct_cplxgain'))
    open_system('sldemo_lct_cplxgain')
    open_system('sldemo_lct_cplxgain/complex_gain')
    sim('sldemo_lct_cplxgain')
end




displayEndOfDemoMessage(mfilename)
