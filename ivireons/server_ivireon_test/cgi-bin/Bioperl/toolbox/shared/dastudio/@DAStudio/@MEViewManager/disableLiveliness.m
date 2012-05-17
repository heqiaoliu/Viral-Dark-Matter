function disableLiveliness(h)
% keep changes on this view hierarchy from being propagated

%   Copyright 2009-2010 The MathWorks, Inc.

% disable liveliness for all managed views
views = find(h, '-isa', 'DAStudio.MEView');
for i = 1:length(views)
    views(i).disableLiveliness;
end

h.ActiveViewListener             = [];
h.MEViewAddedListener            = [];
h.MEViewRemovedListener          = [];
h.IsCollapsedListener            = [];
h.MEViewModeChangedListener      = [];
h.MESearchPropertiesAddedListener = [];
h.MESortChangedListener          = [];
