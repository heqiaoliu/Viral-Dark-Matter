% WORKSPACEVAR creates a Simulink.WorkspaceVar object
%
% VAR = Simulink.WorkspaceVar('NAME', 'WORKSPACE') creates a 
% Simulink.WorkspaceVar with name NAME and Workspace WORKSPACE.
%
% VAR = Simulink.WorkspaceVar({'NAME1', 'NAME2', ...}, 'WORKSPACE') creates a
% vector of Simulink.WorkspaceVar objects.
%
% VAR = Simulink.WorkspaceVar(STRUCT_WITH_NAME_PROP, 'WORKSPACE') creates a 
% vector of Simulink.WorkspaceVar objects with the name property
% set to the corresponding name field on the struct input.
%
%     Examples:
%     
%     % Create a Simulink.WorkspaceVar for a specific variable
%     var = Simulink.WorkspaceVar('k', 'base workspace');
%
%     % Create a Simulink.WorkspaceVar for all the variables in 
%     % the base workspace
%     vars = Simulink.WorkspaceVar(who, 'base workspace');
%
%     % Create a Simulink.WorkspaceVar for all the variables in a
%     % model workspace
%     mdlWks = get_param('mymodel', 'ModelWorkspace');
%     vars = Simulink.WorkspaceVar(whos(mdlWks), 'mymodel');
%     
%     % Create a Simulink.WorkspaceVar vector for all the variables
%     % in a mask workspace
%     maskVars = get_param('mymodel/maskblock', 'MaskWSVariables');
%     vars = Simulink.WorkspaceVar(maskVars, 'mymodel/maskblock');
%
%     See also Simulink.WorkspaceVar.intersect, Simulink.WorkspaceVar.setdiff,
%     Simulink.findVars, find_system.

%   Copyright 2009-2010 The MathWorks, Inc.
