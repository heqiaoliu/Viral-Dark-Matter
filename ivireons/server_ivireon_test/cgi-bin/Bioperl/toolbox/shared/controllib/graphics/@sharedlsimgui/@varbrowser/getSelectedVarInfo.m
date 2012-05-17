function varStruc = getSelectedVarInfo(h)

% GETSELECTEDVARINFO  Retrieves the selected variable structure 

% Author(s): 
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:38 $


thisSelection = h.javahandle.getSelectedRows;
varStruc = [];
if ~isempty(thisSelection)
    varStruc = h.variables(double(thisSelection(1))+1);
end

