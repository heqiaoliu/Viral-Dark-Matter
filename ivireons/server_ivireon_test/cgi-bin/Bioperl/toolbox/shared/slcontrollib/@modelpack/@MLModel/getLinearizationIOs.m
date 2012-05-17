function ports = getLinearizationIOs(this, varargin)
% GETLINEARIZATIONIOS Returns the selected linearization port identifier
% objects.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/11/09 20:59:46 $

allports = this.LinearizationPorts;

if (nargin == 1)
  % All
  ports = allports;
elseif (nargin == 2) && isnumeric(varargin{1})
  % Indexed
  ports = allports(varargin{1});
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end
