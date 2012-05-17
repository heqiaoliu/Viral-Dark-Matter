function setActiveView(this, view)
% Set active view for the domain.

%   Copyright 2009 The MathWorks, Inc.

this.ActiveView = view;
if ~isempty(view)
    this.ActiveViewReason = DAStudio.message('Shared:DAS:ReasonRecentlyUsed');
end