function states = getStates(this, varargin)
% GETSTATES Returns all or specified state information.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/11/09 21:00:56 $

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
