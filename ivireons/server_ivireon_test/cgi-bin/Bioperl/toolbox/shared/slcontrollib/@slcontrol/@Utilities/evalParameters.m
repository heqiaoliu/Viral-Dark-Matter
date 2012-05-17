function s = evalParameters(this, model, names)
% EVALPARAMETERS Evaluates model parameters in appropriate workspace.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.6.2.1 $ $Date: 2010/06/14 14:28:31 $

% Localize parameters in model or base workspace
[WS,WSname] = findParametersWS(this, model, names);
s = struct('Name', names, 'Value', [], 'Workspace', WS, 'WorkspaceName', WSname);

for ct = 1:numel(names)
  [varName,idx] = strtok(names{ct},'.({');
  try
    % Use slresolve to find the variable value
    if strcmp(WS{ct}, 'base')
      % Use main model to resolve base wksp variables
      varValue = slResolve(varName, model, 'variable');
    else
      % Use respective model to resolve model wksp variables
      varValue = slResolve(varName, WSname{ct}, 'variable');
    end
  catch E
    ctrlMsgUtils.error( 'SLControllib:slcontrol:ParameterNotFound', names{ct} );
  end

  % If there was any indexing apply that now
  if isempty(idx)
    s(ct).Value = varValue;
  else
    cmd = strcat('varValue',idx);
    try
      s(ct).Value = eval(cmd);
    catch E
      ctrlMsgUtils.error( 'SLControllib:slcontrol:ParameterNotFound', names{ct} );
    end
  end
end
