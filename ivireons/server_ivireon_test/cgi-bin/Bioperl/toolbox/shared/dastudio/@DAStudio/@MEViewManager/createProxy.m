function proxy = createProxy(h)

%   Copyright 2009 The MathWorks, Inc.

h.VMProxy = [];
% Create view manager's proxy.
proxy = DAStudio.MEViewManager();
% Create views for proxy
allViews = copy(find(h, '-isa', 'DAStudio.MEView'));
for i = 1:length(allViews)
    view = allViews(i);
    proxy.addView(view);
end
% Active view information
if ~isempty(h.getActiveView)
    proxy.ActiveView = copy(h.ActiveView);
end
% Domain info
proxy.Domains = copy(h.Domains);
% The views in these domains still refer to old views. Update.
for i = 1:length(proxy.Domains)
    domainInfo = proxy.Domains(i);
    domainInfo.ViewManager = proxy;
    if ~isempty(domainInfo)
        dView = domainInfo.getActiveView();
        if ~isempty(dView)
            % find actual view
            view = proxy.getView(dView.Name);
            if ~isempty(view)
                domainInfo.setActiveView(view);
            end
        end
    end
end
% Suggestion mechanism
proxy.SuggestionMode = h.SuggestionMode;
%
schema.prop(proxy, 'BufferedViews', 'handle vector');