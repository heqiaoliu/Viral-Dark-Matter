function input = findInput(this, name)
% FINDINPUT Finds the specified input port identifier object(s).

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2005/12/22 18:52:48 $

name  = modelpack.relpath( this.getName, name );
input = modelpack.findObjectsByName(this.getInputs, name);
