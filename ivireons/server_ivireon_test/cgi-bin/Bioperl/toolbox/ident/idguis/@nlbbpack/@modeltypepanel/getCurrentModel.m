function m = getCurrentModel(this)
% return current model

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:30:37 $

if this.Data.StructureIndex==1
    m = this.NlarxPanel.NlarxModel;
else
    m = this.NlhwPanel.NlhwModel;
end
