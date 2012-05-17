function parameters = getParameters(this, varargin)
% GETPARAMETERS Returns all or specified parameter information.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/11/09 21:00:51 $

allparameters = this.Parameters;

if (nargin == 1)
  % All
  parameters = allparameters;
elseif (nargin == 2) && isnumeric(varargin{1})
  % Indexed
  parameters = allparameters(varargin{1});
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end
