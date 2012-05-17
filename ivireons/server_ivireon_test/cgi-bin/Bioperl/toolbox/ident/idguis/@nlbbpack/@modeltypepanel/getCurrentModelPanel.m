function h = getCurrentModelPanel(this)
% return handle to the current model panel

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:30:38 $

if this.Data.StructureIndex==1
    h = this.NlarxPanel;
else
    h = this.NlhwPanel;
end
