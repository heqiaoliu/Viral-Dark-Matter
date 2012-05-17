function [view reason] = getSuggestedView(this)

% Return suggestion. This is ViewManager's method. It will
% check for its active domain and will ask MEViewDomain to
% return an appropriate view.

%   Copyright 2009 The MathWorks, Inc.

view = [];
reason = '';
if ~isempty(this.Domains)
	% Get domain info.
	domainInfo = find(this.Domains, 'Name', this.ActiveDomain);
    if ~isempty(domainInfo)
        % Get domain's active view.
		[view reason] = domainInfo.getActiveView();
	end
end