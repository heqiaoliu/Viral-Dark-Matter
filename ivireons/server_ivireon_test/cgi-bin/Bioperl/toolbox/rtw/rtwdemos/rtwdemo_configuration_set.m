%% Configuring a Model via Command Line
% 
% Real-Time Workshop and Real-Time Workshop(R) Embedded Coder(TM) provide
% numerous configuration options for tailoring the generated
% code.  Code generation options are accessed through the Simulink(R)
% Configuration Parameters, also referred to as the model's
% configuration set.
%
% You will make configuration decisions and tradeoffs depending on how
% you use and interact with the generated code.  In short, you will
% choose a configuration that best matches your needs for debugging,
% traceability, code efficiency, and safety precaution.  Features,
% scripts, and documentation facilitate your creation of an ideal
% model configuration set for your application.
%
% While Real-Time Workshop provides a push-button facility to
% <matlab:showdemo('rtwdemo_usingrtwec') quickly configure and check a
% model for specified objectives>, it is common to automate the model
% configuration procedure using a MATLAB script.  The instructions
% in this demonstration illustrate
%
% * Concepts of working with configuration parameters
% * Documentation to understand the code generation options
% * Tools and scripts to automate the configuration of a model
%
% With these basic skills you are well on your way to setting up an
% ideal automated configuration scheme for your project.
%
%% Configuration Parameter Workflows
% There are many workflows for Configuration Parameters that include persistence 
% within a single model or persistence across multiple models.  Depending
% on your needs you may wish to work with configuration sets as copies or
% references.  This example demonstrates the basics steps for working directly
% with the active configuration set of a model.  For a comprehensive
% description of configuration set features and workflows see
% <matlab:helpview(fullfile(docroot,'toolbox','simulink','helptargets.map'),'ModelConfig') Configuration Sets>
% in the Simulink documentation.
%
%% Configuration Set Basics
% Open a model
model='rtwdemo_configwizard';
open_system(model)
%%
% Obtain the model's active configuration set
cs = getActiveConfigSet(model);

%%
% The Real-Time Workshop product exposes a subset of the code generation options.
% If you are using Real-Time Workshop, select the Generic Real-Time (GRT)
% target.
switchTarget(cs,'grt.tlc',[]);

%%
% The Real-Time Workshop Embedded Coder product exposes the complete set of
% code generation options.  If you are using Real-Time Workshop Embedded Coder,
% select the Embedded Real-Time (ERT) target.
switchTarget(cs,'ert.tlc',[]);

%%
% To automate configuration of models that will be built for both
% GRT and ERT-based targets you will find the configuration
% set *|IsERTTarget|* attribute useful.
isERT = strcmp(get_param(cs,'IsERTTarget'),'on');
%%
% You can interact with code generation options via the model or the
% the configuration set.  This example gets and sets options indirectly
% via the model
inlineParams = get_param(model,'InlineParams');  % Get InlineParams
set_param(model,'InlineParams',inlineParams)     % Set InlineParams
%%
% This example gets and sets options directly via the configuration set.
if isERT
    lifespan = get_param(cs,'LifeSpan');  % Get LifeSpan
    set_param(cs,'LifeSpan',lifespan)     % Set LifeSpan
end
%% Configuration Option Summary
% The full list of code generation options are documented with 
% tradeoffs for debugging, traceability, code efficiency, and safety
% precaution.
%
% * <matlab:helpview(fullfile(docroot,'toolbox','rtw','helptargets.map'),'rtw_param_ref') Real-Time Workshop (GRT) options>
% * <matlab:helpview(fullfile(docroot,'toolbox','ecoder','helptargets.map'),'ecoder_param_ref') Real-Time Workshop Embedded Coder (ERT) options>
%
%% Example Configuration Script
% Real-Time Workshop provides an example configuration script that you can
% use as a starting point for your application.  The full list of relevant
% GRT and ERT code generation options are contained in
% <matlab:edit('rtwconfiguremodel') rtwconfiguremodel.m>.
%
%% Configuration Wizard Blocks
% Real-Time Workshop Embedded Coder provides a set of
% <matlab:helpview(fullfile(docroot,'toolbox','ecoder','helptargets.map'),'ecoder_auto_config_blocks_scripts') Configuration Wizard>
% blocks that automate configuration of a model for a specific goal.
% The pre-defined blocks provide configuration for:
% 
% * ERT optimized for fixed-point
% * ERT optimized for floating-point
% * GRT optimized for fixed/floating-point
% * GRT debug settings for fixed/floating-point
% * Custom (you provide the script)
% 
% Just drop the block into a model and double-click to configure the model.
% See Simulink model
% <matlab:rtwdemo_configwizard rtwdemo_configwizard> for an interactive
% demonstration of these useful blocks.
%
%   Copyright 2007-2008 The MathWorks, Inc.

displayEndOfDemoMessage(mfilename)
