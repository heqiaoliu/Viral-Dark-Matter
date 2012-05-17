function hVal = getValue(this, arg)
% GETVALUE Returns value objects for the specified ports, parameters
% and/or initial states in the model.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2007/12/14 15:01:40 $

if isempty(arg) || isa(arg, 'modelpack.VariableID')
  hId   = arg;
  names = hId.getName; %returns string or cell array of strings
  if ~iscell(names), names = {names}; end
elseif ischar(arg)
  var  = modelpack.varnames(arg);
  hId  = [ ...
     this.findParameter(var); ...
     this.findState(var); ...
     this.findInput(var); ...
     this.findOutput(var) ];
  names = cell(numel(hId),1);
  [names{:}] = deal(arg);
elseif isa(arg, 'modelpack.ParameterSpec')
   hId   = arg.getID;
   names = arg.getName; %returns string or cell array of strings
   if ~iscell(names), names = {names}; end
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end

% Create storage for value objects.
hVal = handle( NaN(size(hId)) );

% Create value objects
for ct = 1:numel(hId)
  h = hId(ct);
  name = names{ct};
  
  if isa(h, 'modelpack.ParameterID')
    % Parameter
    S = evalParameters( this, {name} );
    hVal(ct) = modelpack.ParameterValue(h,name);
    value = S.Value;
  elseif isa(h, 'modelpack.StateID')
    % State
    idx = (h == this.States.getID);
    hVal(ct) = copy( this.States(idx) );
    value = this.States(idx).Value;
  elseif isa(h, 'modelpack.PortID')
    % Port
    hVal(ct) = modelpack.PortValue(h);
    value = 0;
  else
    ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
  end

  if isnumeric(value)
     if ~strcmp(hVal(ct).Name,hVal(ct).getID.getName)
        %Value is not for a parameterID object but some subsref, can set
        %dimensions
        hVal(ct).setDimensions(size(value))
     end
     hVal(ct).Value = value;
  else
     ctrlMsgUtils.error('SLControllib:modelpack:errNumericParameterValue',name);
  end
end
