function this = update(this, flag)
% UPDATE Synchronizes THIS when the underlying model changes.  Updates all
% model properties when requested by a client.
%
% FLAG String to determine what to update: 'all', 'io', 'linio', 'state',
% 'parameter'.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2007 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/11/09 20:59:56 $

% Default arguments
if (nargin < 2 || isempty(flag)), flag = 'all'; end

switch lower(flag)
  case 'io'
    % Update input and output identifiers.
    updateIOPorts(this);
  case 'linio'
    % Update linearization I/O identifiers.
    updateLinearizationPorts(this);
  case 'state'
    % Update state identifiers and values.
    updateStates(this);
  case 'parameter'
    % Update parameter identifiers.
    updateParameters(this);
  case 'all'
    % Update everything.
    updateIOPorts(this);
    updateLinearizationPorts(this);
    updateStates(this);
    updateParameters(this);
  otherwise
    ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end
