function setcurrentvariables(hVars, vars)
%SETCURRENTVARIABLES Sets the variable names for the specified filter
%   SETCURRENTVARIABLES(hVARS, VARS) Sets the variable names for the
%   specified filter in hVARS to VARS.  VARS must be a structure with
%   2 fields ('var' & 'length').  These fields must contains a cell array
%   of 2 strings.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2007/12/14 15:20:08 $

% This might be able to be a private method.

field = get(hVars, 'CurrentStructure');

if isfield(hVars.VariableNames, field),
    
    % Set the fields of the structure with the input variables
    vars  = setfield(hVars.VariableNames, field, vars);
    set(hVars, 'VariableNames', vars);
else
    error(generatemsgid('NotSupported'),'That structure is not available.');
end

% Announce that new variables have been specified.
send(hVars, 'NewVariables', handle.EventData(hVars, 'NewVariables'));

% [EOF]
