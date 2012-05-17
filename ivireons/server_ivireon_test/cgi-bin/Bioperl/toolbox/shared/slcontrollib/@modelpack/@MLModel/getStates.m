function states = getStates(this, varargin)
% GETSTATES Returns the selected state identifier objects.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/11/09 20:59:52 $

if ~isempty(this.States)
  allstates = this.States.getID;
else
  allstates = [];
end

if (nargin == 1)
  % All
  states = allstates;
elseif (nargin == 2) && isnumeric(varargin{1})
  % Indexed
  states = allstates(varargin{1});
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end
