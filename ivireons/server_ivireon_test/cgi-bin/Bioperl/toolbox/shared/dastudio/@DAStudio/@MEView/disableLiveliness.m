function disableLiveliness(h)
% keep changes on this view from being propagated to the view manager

%   Copyright 2009-2010 The MathWorks, Inc.

h.PropertiesListener      = [];
h.MEViewPropertyListeners = [];
h.GroupChangedListener    = [];