function parameter = findParameter(this, fullname)
% FINDPARAMETER  Returns the parameter identifier objects specified by
% their (partial) full name.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2006/09/30 00:24:07 $

parameter = modelpack.utFindObjectsByName(this.getParameters, fullname);
