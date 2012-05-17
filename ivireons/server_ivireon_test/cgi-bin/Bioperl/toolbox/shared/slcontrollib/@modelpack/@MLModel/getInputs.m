function inputs = getInputs(this, varargin)
% GETINPUTS Returns the selected input port identifier objects.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/11/09 20:59:44 $

allinputs = [];

% Get all inputs
for ct = 1:length(this.IOPorts)
  h = this.IOPorts(ct);

  % Add input ports
  if strcmp(h.getType, 'Input')
    allinputs = [allinputs; h];
  end
end

if (nargin == 1)
  % All
  inputs = allinputs;
elseif (nargin == 2) && isnumeric(varargin{1})
  % Indexed
  inputs = allinputs(varargin{1});
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end
