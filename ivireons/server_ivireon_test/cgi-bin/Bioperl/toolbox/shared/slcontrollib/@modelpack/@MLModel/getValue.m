function hVal = getValue(this, arg)
% GETVALUE Returns value objects for the specified ports, parameters
% and/or initial states in the model.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/11/09 20:59:53 $

if isempty(arg) || isa(arg, 'modelpack.VariableID')
  hId = arg;
elseif ischar(arg)
  [var, subs] = modelpack.varnames(arg);

  hId = [ this.findParameter(var); ...
          this.findState(var); ...
          this.findInput(var); ...
          this.findOutput(var) ];
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end

% Create storage for value objects.
hVal = handle( NaN(size(hId)) );

% Create value objects
for ct = 1:length(hId)
  h = hId(ct);

  if isa(h, 'modelpack.ParameterID')
    % Parameter
    idx = (h == this.Parameters.getID);
    hVal(ct) = copy( this.Parameters(idx) );
    value = this.Parameters(idx).Value;
  elseif isa(h, 'modelpack.StateID')
    % State
    idx = (h == this.States.getID);
    hVal(ct) = copy( this.States(idx) );
    value = this.States(idx).Value;
  elseif isa(h, 'modelpack.PortID')
    % Port
    hVal(ct) = modelpack.PortValue(this, h);
    value = 0;
  else
    ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
  end

  hVal(ct).Value = value;
end
