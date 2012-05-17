function hSpec = getSpec(this, arg)
% GETSPEC Returns specification objects for the specified ports, parameters,
% and/or initial states in the model.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2007/12/14 15:01:39 $

if isempty(arg) || isa(arg, 'modelpack.VariableID')
  hId = arg;
  names = hId.getName; %returns string or cell array of strings
  if ~iscell(names), names = {names}; end
elseif ischar(arg)
  var = modelpack.varnames(arg);

  hId = [ this.findParameter(var); ...
     this.findState(var); ...
     this.findInput(var); ...
     this.findOutput(var) ];
  names = cell(numel(hId),1);
  [names{:}] = deal(arg);
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end

% Create storage for spec objects.
hSpec = handle( NaN(size(hId)) );

% Create value objects
for ct = 1:length(hId)
  h = hId(ct);
  name = names{ct};

  if isa(h, 'modelpack.ParameterID')
    % Parameter
    hSpec(ct) = modelpack.ParameterSpec(h,name);
    hValue    = this.getValue(hSpec(ct));
    if ~strcmp(h.getName,name)
       %Have subsref, need to set dimensions
       hSpec(ct).setDimensions(size(hValue.Value));
    end
    hSpec(ct).InitialValue = hValue.Value;
    hSpec(ct).TypicalValue = hValue.Value;
  elseif isa(h, 'modelpack.StateID')
    % State
    hSpec(ct) = modelpack.StateSpec(h);
  elseif isa(h, 'modelpack.PortID')
    % Port
    hSpec(ct) = modelpack.PortSpec(h);
  else
    ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
  end

end
