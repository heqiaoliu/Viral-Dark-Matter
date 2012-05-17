function thisTab = findtab(h,name)

% Copyright 2004 The MathWorks, Inc.

%% Find the axes tab
thisTab = [];
if ~isempty(h.Tabs) 
    ind = find(strcmp(name,{h.Tabs.('Name')}));
    if ~isempty(ind)
       thisTab = h.Tabs(ind);
    end
end