function parameter = findParameter(this, name)
% FINDPARAMETER Finds the specified parameter identifier object(s).

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2005/12/22 18:52:51 $

if ~isempty(this.Parameters)
  allparams = this.Parameters.getID;
else
  allparams = [];
end

name      = modelpack.relpath( this.getName, name );
parameter = modelpack.findObjectsByName(allparams, name);
