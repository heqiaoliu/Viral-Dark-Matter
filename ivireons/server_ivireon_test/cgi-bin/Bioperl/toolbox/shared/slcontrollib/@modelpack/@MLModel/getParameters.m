function parameters = getParameters(this, varargin)
% GETPARAMETERS Returns the selected parameter identifier objects.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/11/09 20:59:48 $

if ~isempty(this.Parameters)
  allparameters = this.Parameters.getID;
else
  allparameters = [];
end

if (nargin == 1)
  % All
  parameters = allparameters;
elseif (nargin == 2) && isnumeric(varargin{1})
  % Indexed
  parameters = allparameters(varargin{1});
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end
