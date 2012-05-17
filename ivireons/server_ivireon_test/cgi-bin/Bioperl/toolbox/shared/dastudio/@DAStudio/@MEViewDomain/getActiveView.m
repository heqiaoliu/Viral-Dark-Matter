function [view reason] = getActiveView(this)
% Get active view for the domain.

%   Copyright 2009 The MathWorks, Inc.

view = this.ActiveView;
% Get factory view if there is not active view yet.
if isempty(view) || ~ishandle(view)
	% Return factory's version. This could be empty.
	view = this.getFactoryView();
    this.ActiveView = view;
    if ~isempty(view)
        this.ActiveViewReason = DAStudio.message('Shared:DAS:ReasonDefault');
    end
end
reason = this.ActiveViewReason;
