function outputs = getOutputs(this, varargin)
% GETOUTPUTS Returns the selected output port identifier objects.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/11/09 20:59:47 $

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
