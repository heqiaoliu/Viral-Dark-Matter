function updatePreview(h)

% Copyright 2006 The MathWorks, Inc.

%% Put the preview axes and legends to the front of the child order

c = get(h.Figure,'Children');
ax = findobj(c,'type','axes');
[junk,I] = ismember(ax,c);
c(I) = [];
c = [ax(:);c];
set(h.Figure,'Children',c);