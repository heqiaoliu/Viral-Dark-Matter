function varName = utCheckVariableSubsref(varID, subsName)
% UTCHECKVARIABLESUBSREF Checks whether the subscripted variable (port, state,
% parameter) name is compatible with the variable identifier object.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/11/09 20:59:36 $

if isa(varID, 'modelpack.ParameterID')
  varName = LocalGetVariableName(varID, subsName, []);
elseif isa (varID, 'modelpack.StateID')
  varName = LocalGetVariableName(varID, subsName, '(');
elseif isa(varID, 'modelpack.PortID')
  varName = LocalGetVariableName(varID, subsName, '(');
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end

% ----------------------------------------------------------------------------
function varName = LocalGetVariableName(varID, subsName, delimiters)
% Get variable name
if isempty(subsName)
  varName = varID.getName;
else
  [name, subs] = modelpack.varnames(subsName, delimiters);

  if strcmp(name, varID.getName)
    varName = [varID.getName subs];
  else
    ctrlMsgUtils.error( 'SLControllib:slcontrol:VariableNotFound', subsName );
  end
end
