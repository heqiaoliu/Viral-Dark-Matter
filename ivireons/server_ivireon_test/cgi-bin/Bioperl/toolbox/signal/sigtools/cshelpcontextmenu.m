function varargout = cshelpcontextmenu(hFig, hItem, tagStr, toolname)
%CSHELPCONTEXTMENU   Add a "What's This?" context menu.
%   HC = CSHELPCONTEXTMENU(HITEM,TAGSTR,TOOLNAME) adds a context menu to
%   the uicontrol HITEM.  TAGSTR is assigned as the tag to the UIMENU.
%   TOOLNAME defines which TOOLNAME_help.m file could be used in
%   determining the documentation mapping. The handle to  the contextmenu
%   is returned.
%
%   See also CSHELPENGINE, CSHELPGENERAL_CB, RENDER_CSHELPBTN

%   Author(s): D.Orofino, V.Pellissier
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.2.4.6 $  $Date: 2009/04/21 04:36:28 $ 

if ischar(hItem),
    error(nargchk(3,3,nargin,'struct'));
    toolname = tagStr;
    tagStr   = hItem;
    hItem    = hFig;
    hFig     = ancestor(hItem(1), 'figure');
else
    error(nargchk(4,4,nargin,'struct'));
end

tag = ['WT?' tagStr];

hm = [];
hc = [];
if length(hItem) == 1
    hc = get(hItem, 'UIContextMenu');
    if ~isempty(hc)
        hm = findobj(hc, 'Label', 'What''s This?');
    end
end

if isempty(hc)
    hc = uicontextmenu('parent', hFig);
end
if isempty(hm)
    hm = uimenu('Label', '"What''s This?"',...
        'Parent', hc);
    set(hItem,'uicontextmenu',hc);
end
set(hm, 'Callback', {@cshelpengine,toolname,tag}, ...
    'Tag', tag);

if nargout >= 1
    varargout{1} = hc;
end

% [EOF]
