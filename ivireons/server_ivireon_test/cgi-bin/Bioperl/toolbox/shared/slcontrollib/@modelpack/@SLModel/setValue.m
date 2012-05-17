function setValue(this, arg, values)
% SETVALUE Sets the value of the specified parameters and/or initial states.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2009/12/22 18:57:47 $

%Check to see if passed a Parameter value object
if nargin < 3 && isa(arg,'modelpack.VariableValue')
   values = get(arg,{'Value'});
end

if ischar(arg)
  var = modelpack.varnames(arg);
  hId = [ this.findParameter(var); ...
     this.findState(var)];
  names = cell(numel(hId),1);
  [names{:}] = deal(arg);
elseif isa(arg, 'modelpack.VariableID')
  hId   = arg;
  names = arg.getName; %returns string or cell array of strings
  if ~iscell(names), names = {names}; end
elseif isa(arg, 'modelpack.VariableValue') || isa(arg, 'modelpack.VariableSpec')
  hId   = arg.getID;
  names = arg.getName; %returns string or cell array of strings
  if ~iscell(names), names = {names}; end
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end

if ~iscell(values), values = {values}; end

% Set values
utils = slcontrol.Utilities;
for ct = 1:length(hId)
  h    = hId(ct);
  name = names{ct};
  var  = modelpack.varnames(name);

  if isa(h, 'modelpack.ParameterID')
    % Parameter
    [WS, WSname] = utils.findParametersWS(this.Name, {var});
    pv = struct( 'Name',          name, ...
                 'Value',         values{ct}, ...
                 'Workspace',     WS, ...
                 'WorkspaceName', WSname);

    % Perform assignment
    assignParameters(this, pv)
  elseif isa(h, 'modelpack.StateID')
    % State
    idx = (h == this.States.getID);
    this.States(idx).Value = values{ct};
  else
    ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
  end
end
