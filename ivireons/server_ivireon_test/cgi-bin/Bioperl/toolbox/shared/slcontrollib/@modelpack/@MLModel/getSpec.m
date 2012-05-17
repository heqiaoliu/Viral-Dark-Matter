function hSpec = getSpec(this, arg)
% GETSPEC Returns specification objects for the specified ports, parameters,
% and/or initial states in the model.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/11/09 20:59:50 $

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

% Create storage for spec objects.
hSpec = handle( NaN(size(hId)) );

% Create value objects
for ct = 1:length(hId)
  h = hId(ct);

  if isa(h, 'modelpack.ParameterID')
    % Parameter
    hSpec(ct) = modelpack.ParameterSpec(this, h);
  elseif isa(h, 'modelpack.StateID')
    % State
    hSpec(ct) = modelpack.StateSpec(this, h);
  elseif isa(h, 'modelpack.PortID')
    % Port
    hSpec(ct) = modelpack.PortSpec(this, h);
  else
    ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
  end

  value = this.getValue(h).Value;
  hSpec(ct).InitialValue = value;
  hSpec(ct).TypicalValue = value;
end
