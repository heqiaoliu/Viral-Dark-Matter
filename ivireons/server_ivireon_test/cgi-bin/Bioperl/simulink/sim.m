%SIM Simulate a Simulink model
%
%   SimOut = SIM('MODEL', PARAMETERS) simulates your Simulink model, where 
%   'PARAMETERS' represents a list of parameter name-value pairs, a structure 
%   containing parameter settings, or a configuration set. The SimOut
%   returned by the SIM command is an object that contains all of the logged
%   simulation results. Optional PARAMETERS can be used to override existing 
%   block diagram configuration parameters for the duration of the simulation.
%
%   This syntax is referred to as the 'Single-Output Format'.
%
%   SINGLE-OUTPUT FORMAT
%   --------------------
%   SimOut = SIM('MODEL','PARAMETER_NAME1',VALUE1,'PARAMETER_NAME2',VALUE2, ...)
%   SimOut = SIM('MODEL', PARAM_NAME_VAL_STRUCT)
%   SimOut = SIM('MODEL', CONFIGSET)
%
%   All simulation outputs (logged time, states, and signals) are returned in a
%   single Simulink.SimulationOutput object. Using the model's Configuration
%   Parameters Data Import/Export dialog, you define the model time, states, and
%   output to be logged. You can log signals using blocks such as the
%   To Workspace and Scope blocks. The Signal & Scope Manager can directly
%   log signals.
%
%   Where:
%
%     SimOut                : Returned Simulink.SimulationOutput object
%                             containing all of the simulation output.
%     'MODEL'               : Name of a block diagram model.
%     'PARAMETER_NAMEk'     : Name of the Configuration or Block Diagram
%                             parameter.
%     VALUEk                : Value of the corresponding Configuration or
%                             Block Diagram parameter.
%     PARAM_NAME_VAL_STRUCT : This is a structure whose fields are the names
%                             of the block diagram or the configuration
%                             parameters that are being changed for the
%                             simulation. The corresponding values are
%                             the corresponding parameter values.
%     CONFIGSET             : The set of configuration parameters for a model.
%
%   The single-output format makes the SIM command compatible with PARFOR
%   by eliminating any transparency issues. See "Running Parallel
%   Simulations" in the Simulink documentation for further details.
%
%   Example 1:
%     simOut = sim('vdp','SimulationMode','rapid','AbsTol','1e-5',...
%                  'SaveState','on','StateSaveName','xoutNew',...
%                  'SaveOutput','on','OutputSaveName','youtNew');
%     simOutVars = simOut.who;
%     yout = simOut.find('youtNew');
%
%
%   Example 2:
%     paramNameValStruct.SimulationMode = 'rapid';
%     paramNameValStruct.AbsTol         = '1e-5';
%     paramNameValStruct.SaveState      = 'on';
%     paramNameValStruct.StateSaveName  = 'xoutNew';
%     paramNameValStruct.SaveOutput     = 'on';
%     paramNameValStruct.OutputSaveName = 'youtNew';
%     simOut = sim('vdp',paramNameValStruct);
%
%   Example 3:
%     mdl = 'vdp';
%     load_system(mdl);
%     simMode = get_param(mdl, 'SimulationMode');
%     set_param(mdl, 'SimulationMode', 'rapid');
%     cs = getActiveConfigSet(mdl);
%     mdl_cs = cs.copy;
%     set_param(mdl_cs,'AbsTol','1e-5',...
%               'SaveState','on','StateSaveName','xoutNew',...
%               'SaveOutput','on','OutputSaveName','youtNew');
%     simOut = sim(mdl, mdl_cs);
%     set_param(mdl, 'SimulationMode', simMode);
%
%   DEFAULTS:
%
%     1.  R = SIM('MODEL') returns the result R as either a 
%         Simulink.SimulationOutput object or a time vector that is compatible 
%         with a Simulink version prior to 7.4 (R2009b).
%
%         To make SIM('MODEL') return in the single-output format, use the
%         ReturnWorkspaceOutputs option:
%
%         SimOut = SIM('MODEL', 'ReturnWorkspaceOutputs', 'on')
%
%
%     2.  To set the single-output format as the default format, select the
%         'Return as single output' option on the Data Import/Export pane of 
%         the Configuration Parameters dialog box and save the model.
% 
%
%
%   See also SLDEBUG, SIM in PARFOR

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.19.2.9.2.1 $
%   Built-in function.
