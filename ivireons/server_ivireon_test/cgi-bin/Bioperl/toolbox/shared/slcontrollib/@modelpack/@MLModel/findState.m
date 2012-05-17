function state = findState(this, name)
% FINDSTATE Finds the specified state identifier object(s).

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2005/12/22 18:52:52 $

if ~isempty(this.States)
  allstates = this.States.getID;
else
  allstates = [];
end

name  = modelpack.relpath(this.getName, name);
state = modelpack.findObjectsByName(allstates, name);
