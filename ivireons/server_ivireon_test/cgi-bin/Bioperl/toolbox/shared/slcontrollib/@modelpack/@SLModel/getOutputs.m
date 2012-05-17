function outputs = getOutputs(this, varargin)
% GETOUTPUTS Returns all or specified output port information.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/11/09 21:00:48 $

alloutputs = [];

% Get all outputs
for ct = 1:length(this.IOPorts)
  h = this.IOPorts(ct);

  % Add output ports
  if strcmp(h.getType, 'Output')
    alloutputs = [alloutputs; h];
  end
end

if (nargin == 1)
  % All
  outputs = alloutputs;
elseif (nargin == 2) && isnumeric(varargin{1})
  % Indexed
  outputs = alloutputs(varargin{1});
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end
