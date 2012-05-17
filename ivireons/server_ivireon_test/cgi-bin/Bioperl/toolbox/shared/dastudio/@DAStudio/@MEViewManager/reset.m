function reset(h)
% reset
% Reset the view manager to its factory state overriding any preferences.
%

%   Copyright 2009 The MathWorks, Inc.

% remove any existing views and install the factory ones w/o side effects
h.disableLiveliness;
delete(find(h, '-isa', 'DAStudio.MEView'));
factoryViews = h.getFactoryViews();
for i = 1:length(factoryViews)
    h.addView(factoryViews(i));
end
h.enableLiveliness;

% update the ActiveView
h.ActiveView = find(h, '-isa', 'DAStudio.MEView', 'Name', 'Default');

% save the new configuration to preferences
h.save(h);