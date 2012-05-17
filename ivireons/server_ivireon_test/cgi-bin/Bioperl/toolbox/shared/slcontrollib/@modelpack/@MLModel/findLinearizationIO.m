function port = findLinearizationIO(this, name)
% FINDLINEARIZATIONIO Finds the specified linearization port identifier object.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2005/12/22 18:52:49 $

name = modelpack.relpath( this.getName, name );
port = modelpack.findObjectsByName(this.getLinearizationIOs, name);
