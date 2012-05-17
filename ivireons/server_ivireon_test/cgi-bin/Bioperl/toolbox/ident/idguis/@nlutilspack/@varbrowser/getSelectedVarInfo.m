function varStruc = getSelectedVarInfo(h)
% GETSELECTEDVARINFO  Retrieves the selected variable structure 

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:33:31 $

thisSelection = h.javahandle.getSelectedRows;
varStruc = [];
if ~isempty(thisSelection)
    varStruc = h.variables(double(thisSelection(1))+1);
end

