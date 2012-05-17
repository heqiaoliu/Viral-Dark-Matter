function output = findOutput(this, name)
% FINDOUTPUT Finds the specified output port identifier object(s).

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2005/12/22 18:52:50 $

name   = modelpack.relpath( this.getName, name );
output = modelpack.findObjectsByName(this.getOutputs, name);
