function port = findLinearizationIO(this, fullname)
% FINDLINEARIZATIONIO Finds the specified linearization port identifier object.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2006/09/30 00:24:05 $

port = modelpack.utFindObjectsByName(this.getLinearizationIOs, fullname);
