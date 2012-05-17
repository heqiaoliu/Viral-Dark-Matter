%% Replacing Math Functions and Operators
% This demo shows you how to use target function libraries (TFLs) to 
% replace operators and functions in the generated code. The models 
% described below demonstrate the replacement capabilities. With each 
% example model, a separate target function library is provided to 
% illustrate the creation of operator and function replacements using a 
% <matlab:helpview(fullfile(docroot,'toolbox','ecoder','helptargets.map'),'tfl_mapi') MATLAB(R) based API>
% and how to 
% <matlab:helpview(fullfile(docroot,'toolbox','ecoder','helptargets.map'),'tfl_registration') register them>
% with Simulink(R).
%
% Using target function libraries enables:
%
% * Better integration of model code with external and legacy code, to 
%   reduce code size and verification efforts
% * The use of target specific function implementations, to optimize 
%   performance of the embedded application
%
% The target function library capabilities include:
%
% * Replacement of math functions with target specific function 
%   implementations
% * Replacement of math operations with target specific function 
%   implementations
% * Specifying build information for compiling and building the 
%   replacements with the generated code

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2010/05/20 02:55:26 $


%% Steps in Using a Target Function Library
%
% * Create a table of replacement function entries
% * Register a target function library consisting of one or more tables 
%   using Simulink's sl_customization.m API
% * From the model, select the desired target function library using the
%   Interface pane under Real-Time Workshop(R) in the Configuration Parameters
%   dialog box
% * Generate code for the model with Real-Time Workshop Embedded Coder(TM)
%
% For more information on these steps,
% <matlab:helpview(fullfile(docroot,'toolbox','ecoder','helptargets.map'),'tfl_overview') look here>.

%% Addition and Subtraction Operator Replacement for Built-in Integers
% This example target function library replaces '+' and '-' for two input, 
% scalar operations on data types that are built-in integers:
%
% * int8, uint8
% * int16, uint16
% * int32, uint32
%
% The model <matlab:rtwdemo_tfladdsub rtwdemo_tfladdsub> 
% demonstrates these replacements. For more information on operator 
% replacement, 
% <matlab:helpview(fullfile(docroot,'toolbox','ecoder','helptargets.map'),'tfl_operators') look here>.
open_system('rtwdemo_tfladdsub')

%% Multiplication and Division Operator Replacement for Built-in Integers
% This example target function library replaces '*' and '/' for two input, 
% scalar operations on data types that are built-in integers:
%
% * int8, uint8
% * int16, uint16
% * int32, uint32
%
% The model <matlab:rtwdemo_tflmuldiv rtwdemo_tflmuldiv> demonstrates these 
% replacements.
open_system('rtwdemo_tflmuldiv')

%% Fixed Point Operator Replacement for Basic Operators
% This example target function library replaces '+', '-', '*' and '/' for 
% two input, scalar operations on data types that are fixed point. 
% Replacements can be defined as matching:
%
% * A specific slope/bias scaling combination on the inputs and output
% * A specific binary point scaling combination on the inputs and output
% * A relative scaling between the inputs and output
% * The same slope value and a zero net bias across the inputs and output
%
% The model <matlab:rtwdemo_tflfixpt rtwdemo_tflfixpt> demonstrates these 
% replacements.
%
% *Note:* Using fixed point data types in a model requires a Simulink Fixed
% Point license.
open_system('rtwdemo_tflfixpt')

%% Addition and Subtraction Operator Replacement in Embedded MATLAB Coder
% This example target function library replaces '+' and '-' for two input, 
% scalar operations on integer data types when using the |emlc| command.
%
% For more information on operator replacement, 
% <matlab:helpview(fullfile(docroot,'toolbox','ecoder','helptargets.map'),'tfl_operators') look here>.
% For more information on embeddable C-code generation using Embedded 
% MATLAB Coder, <matlab:helpview(fullfile(docroot,'toolbox','rtw','helptargets.map'),'working_with_emlc_chapter') look here>.
%
% There is a MATLAB program that is needed to run this demonstration. Copy it to
% a temporary directory. This step requires write-permission to the
% system's temporary directory.
%
% To see the MATLAB file, <matlab:edit(fullfile(matlabroot,'toolbox','rtw','rtwdemos','tfl_demo','addsub_two_int16.m')) look here>.
emlcdir = [tempname filesep 'emlcdir'];
if ~exist(emlcdir,'dir')
    mkdir(emlcdir);
end
emlcsrc = ...
    fullfile(matlabroot,'toolbox','rtw','rtwdemos','tfl_demo','addsub_two_int16.m');
copyfile(emlcsrc,emlcdir,'f');
emlcurdir = pwd;
cd(emlcdir);

%% Set Embedded MATLAB Coder to Use the Target Function Library
% Set up the configuration parameters for an RTW build and define the 
% operation input type.
% To see the TFL table definition file, <matlab:edit(fullfile(matlabroot,'toolbox','rtw','rtwdemos','tfl_demo','tfl_table_addsub.m')) look here>.
addpath(fullfile(matlabroot,'toolbox','rtw','rtwdemos','tfl_demo'));
sl_refresh_customizations;
rtwConfig = emlcoder.RTWConfig('ert');
rtwConfig.TargetFunctionLibrary = 'Addition & Subtraction Examples';
rtwConfig.GenerateReport = false;
rtwConfig.LaunchReport = false;

t = int16(2);

%% Compile the MATLAB program into a C Source File
% Compile the MATLAB program using the configuration parameters that point to the
% desired target function library and the example input class defined in the
% previous step as input parameters to the |emlc| command.
emlc -T rtw -s rtwConfig -c addsub_two_int16 -eg {t, t};

%% Inspect the Embedded MATLAB Coder Generated Code
% After compiling, you may want to explore the generated source code.
% <matlab:edit(fullfile(emlcdir,'emcprj','rtwlib','addsub_two_int16','addsub_two_int16.c'))>

%% Math Function Replacement 
% Target function libraries support the replacement of a variety of 
% functions. For a full list of supported functions
% <matlab:helpview(fullfile(docroot,'toolbox','ecoder','helptargets.map'),'tfl_supportedfcns') look here>.
%
% The model <matlab:rtwdemo_tflmath rtwdemo_tflmath> demonstrates these 
% replacements.
% For more information on math function replacement, 
% <matlab:helpview(fullfile(docroot,'toolbox','ecoder','helptargets.map'),'tfl_mathfcns') look here>.
cd(emlcurdir);
open_system('rtwdemo_tflmath')

%% Matrix Operator Replacement 
% Target function libraries support replacement of the following matrix
% operations:
% 
% addition, subtraction, multiplication,transposition, conjugate, hermitian
%
% The model <matlab:rtwdemo_tflmatops rtwdemo_tflmatops> demonstrates some 
% of these replacements. Supported types include:
%
% * single, double
% * int8, uint8
% * int16, uint16
% * int32, uint32
% * csingle, cdouble
% * cint8, cuint8
% * cint16, cuint16
% * cint32, cuint32
% * fixed-point integers
% * mixed types (different type on each input)
%
% <matlab:helpview(fullfile(docroot,'toolbox','ecoder','helptargets.map'),'tfl_matops') look here>.
open_system('rtwdemo_tflmatops')

%% BLAS Support 
% In addition, matrix multiplication can be mapped to Basic Linear Algebra 
% Subroutines (BLAS).The following operations can be mapped to a BLAS Subroutine:
% 
% matrix multiplication, matrix multiplication with transpose on single or both inputs, 
% and matrix multiplication with hermitian operation on single or both inputs
%
% The model <matlab:rtwdemo_tflblas rtwdemo_tflblas>
% demonstrates mapping to BLAS xGEMM and xGEMV subroutines.
open_system('rtwdemo_tflblas')

%% Other Scalar Operator Replacements 
% Target function libraries support replacement of the following scalar
% operations:
% 
% Complex operations including - addition, subtraction, multiplication, division, and complex conjugate 
% Other scalar operations including - data type cast, shift left, arithmetic shift right, logical shift right
%
% The model <matlab:rtwdemo_tflscalarops rtwdemo_tflscalarops> demonstrates some 
% of these replacements. Supported types include:
%
% * single, double
% * int8, uint8
% * int16, uint16
% * int32, uint32
% * csingle, cdouble
% * cint8, cuint8
% * cint16, cuint16
% * cint32, cuint32
% * fixed-point integers
% * mixed types (different type on each input)
%
% <matlab:helpview(fullfile(docroot,'toolbox','ecoder','helptargets.map'),'tfl_operators') look here>
open_system('rtwdemo_tflscalarops')

%% Custom TFL Entry
% TFLs support the creation of custom entries.  You can create your own
% TFL entry by subclassing from either RTW.TflCFunctionEntryML or
% RTW.TflCOperationEntryML. Your entry class must implement a do_match
% method that customizes your matching logic or modifies the matched entry. 
% The do_match method must have a fixed preset signature.  
% The model <matlab:rtwdemo_tflcustomentry rtwdemo_tflcustomentry> 
% demonstrates how to use custom entries to create your own 
% matching function and how to modify the matched entry by injecting constants 
% as additional implementation function arguments. 
% For more information on Custom TFL entries,
% <matlab:helpview(fullfile(docroot,'toolbox','ecoder','helptargets.map'),'tfl_customentry') look here>.
open_system('rtwdemo_tflcustomentry')

%% Viewer for Target Function Libraries
% A viewer is provided for examining and validating tables and
% their entries. For example, to view the table 'tfl_tablemuldiv', the 
% commands are:
tfl = tfl_table_muldiv;
me = RTW.viewTfl(tfl);

%%
% For more information on the target function library viewer,
% <matlab:helpview(fullfile(docroot,'toolbox','ecoder','helptargets.map'),'tfl_viewer') look here>.

%% Build Support
% Each entry in a target function library table can specify build 
% information such as:
%
% * Header file dependencies
% * Source file dependencies
% * Additional include paths
% * Additional source paths
% * Additional link flags
% 
% Additionally, the method RTW.copyFileToBuildDir can be used to locally 
% copy the source and header files specified by an entry. For more 
% information on specifying compilation information, 
% <matlab:helpview(fullfile(docroot,'toolbox','ecoder','helptargets.map'),'tfl_buildsupport') look here>.
%
% *Note:* The models in this demo are configured for code generation only, 
% as the implementations for the replacement functions are not provided.

%% Reserved Identifier Support
% Each function implementation name defined by a entry will be reserved as 
% a unique identifier. Other identifiers can be specified with a table on a
% per-header-file basis. Providing additional reserved identifiers ensures 
% that duplicate symbols and other identifier related compile and link 
% issues do not occur.
%
% For more information on specifying reserved identifiers, 
% <matlab:helpview(fullfile(docroot,'toolbox','ecoder','helptargets.map'),'tfl_identifiers') look here>.

%% Removing the Example Target Function Libraries
% Once finished using the example models, you can remove the example target 
% function libraries and close the example models with the commands:

rmpath(fullfile(matlabroot,'toolbox','rtw','rtwdemos','tfl_demo'));
sl_refresh_customizations;

close_system('rtwdemo_tfladdsub', 0)
close_system('rtwdemo_tflmuldiv', 0)
close_system('rtwdemo_tflfixpt', 0)
close_system('rtwdemo_tflmath', 0)
close_system('rtwdemo_tflmatops', 0)
close_system('rtwdemo_tflblas', 0)
close_system('rtwdemo_tflscalarops', 0)
close_system('rtwdemo_tflcblas', 0)
if ~isempty(me)
    me.delete;
end
clear tfl;
clear me;
clear emlcdir;
clear emlcsrc;
clear emlcurdir;
clear n1;
clear rtwConfig;
clear t;

displayEndOfDemoMessage(mfilename)
