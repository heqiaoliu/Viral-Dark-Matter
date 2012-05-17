function inputs = getInputs(this, varargin)
% GETINPUTS Returns all or specified input port information.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/11/09 21:00:45 $

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
