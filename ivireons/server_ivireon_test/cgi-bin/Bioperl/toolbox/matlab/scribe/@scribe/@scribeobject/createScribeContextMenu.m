function res = createScribeContextMenu(hThis,hFig) %#ok
% Given a figure, check for context-menu entries specific to that shape-type and
% figure. If no context-menu has been defined, then create one. It should
% be noted that we are only returning entries to be merged into a larger
% context-menu at a later point in time.

% The context-menu entries will be uniquely identified by a tag based on the shape
% type. Tags should be of the form "package.class.uicontextmenu" and will
% have their visibility set to off.

%   Copyright 2006 The MathWorks, Inc.

error('MATLAB:scribe:purevirtual',...
    'Pure virtual function. Must be implemented by a subclass.');