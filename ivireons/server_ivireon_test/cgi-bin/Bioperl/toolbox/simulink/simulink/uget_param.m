function rtn = uget_param(object, paramName)
% A unified "getparam" utility for Simulink/Stateflow configuration.
%
% Examples:
%     uget_param('model_name', 'SolverMode')
%     uget_param('model_name', 'GenerateSampleERTMain')
%     uget_param('model_name', 'RootIOStructures')
%     uget_param('model_name', 'StateBitSets')
%
% To get the table of commonly used parameters and their valid value group, use
%     uget_param()
%   Note, some RTW targets do not support every parameter in this table.
%
% For a complete list of supported parameters for the current RTW target for a model, use
%     uget_param('model_name', 'ObjectParameters')
%        and
%     cs = getActiveConfigSet('model_name')
%     uget_param(cs, 'ObjectParameters')
%  
% See also USET_PARAM, GET_PARAM, SET_PARAM.

%   Copyright 2002-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2005/06/24 11:22:30 $

persistent warning_issued;

if isempty(warning_issued)
    warning('Simulink:uget_param_obsolete',...
            ['uget_param is an obsolete function, use get_param instead\n\n'...
             'This warning can be turned off by issuing the following '...
             'command at the matlab prompt:\n\n'...
             'warning(''off'',''Simulink:uget_param_obsolete'')\n']);
    % assign any value to warning_issued to prevent spamming of the warning
    warning_issued = true;
end
    
% calling uset_param to read value
if nargin <1
    rtn = uset_param();
elseif nargin <2
    rtn = uset_param(object, 'uget_param');
else
    rtn = uset_param(object, 'uget_param', paramName);
end
