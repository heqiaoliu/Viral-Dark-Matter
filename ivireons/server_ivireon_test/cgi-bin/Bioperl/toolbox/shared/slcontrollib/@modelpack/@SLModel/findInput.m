function input = findInput(this, fullname)
% FINDINPUT Returns the input port identifier objects specified by
% their (partial) full name.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2006/09/30 00:24:04 $

input = modelpack.utFindObjectsByName(this.getInputs, fullname);
