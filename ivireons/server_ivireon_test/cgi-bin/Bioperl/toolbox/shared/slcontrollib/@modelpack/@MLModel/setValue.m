function setValue(this, arg, values)
% SETVALUE Sets the value of the specified parameters and/or initial states.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/11/09 20:59:54 $

if ischar(arg)
  [var, subs] = modelpack.varnames(arg);

  hId = [ this.findParameter(var); ...
          this.findState(var)];
elseif isa(arg, 'modelpack.VariableID')
  hId = arg;
elseif isa(arg, 'modelpack.VariableValue') || isa(arg, 'modelpack.VariableSpec')
  hId = arg.getID;
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end

if ~iscell(values)
  values = {values};
end

% Set values
for ct = 1:length(hId)
  h = hId(ct);

  if isa(h, 'modelpack.ParameterID')
    % Parameter
    idx = (h == this.Parameters.getID);
    this.Parameters(idx).Value = values{ct};
  elseif isa(h, 'modelpack.StateID')
    % State
    idx = (h == this.States.getID);
    this.States(idx).Value = values{ct};
  else
    ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
  end
end
