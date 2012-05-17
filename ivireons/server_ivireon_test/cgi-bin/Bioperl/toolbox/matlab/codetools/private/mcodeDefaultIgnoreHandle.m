function [retval] = mcodeDefaultIgnoreHandle(hParent,h)

% Copyright 2003-2006 The MathWorks, Inc.

% By default, do not ignore handle
retval = false;

hParent = handle(hParent);
h = handle(h);

% Ignore all ui components 
% ToDo: GUIDE support will require ui components
classname = class(h);
if strncmp(classname,'ui',2) && strcmpi(get(h,'HandleVisibility'),'off')
  retval = true;
  
elseif strcmpi(classname,'uicontextmenu')
    retval = true;
  
elseif ishghandle(h) && localIsAxesLabel(h)
    retval = false;
    
% Ignore handle if it is an hg object with handle visibility off
elseif (isa(hParent,'hg.GObject') ...
        && strcmp(get(hParent,'HandleVisibility'),'off') ...
        && h==hParent)
    retval = true;

% Ignore children of objects that subclass group or transform objects
elseif isa(hParent,'hg.hggroup') || isa(hParent,'hg.hgtransform')
    hClass = hParent.classhandle;
    hPk = get(hClass,'Package');
    if ~strcmp(get(hPk,'Name'),'hg')
       retval = ~isequal(hParent,h);
    end
end

%----------------------------------------------------------%
function [retval] = localIsAxesLabel(h)
% Check to see if h is an axes label

retval = false;

hParent = get(h,'Parent');
if isa(handle(hParent),'hg.axes')
    labels = [get(hParent,'XLabel'),...
        get(hParent,'YLabel'),...
        get(hParent,'ZLabel'),...
        get(hParent,'Title')];
    if ~isempty(find(labels==double(h))) %#ok
        retval = true;
    end
end