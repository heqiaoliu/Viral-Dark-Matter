function state = findState(this, fullname)
% FINDSTATE Returns the state identifier objects specified by
% their (partial) full name.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2006/09/30 00:24:08 $

state = modelpack.utFindObjectsByName(this.getStates, fullname);
