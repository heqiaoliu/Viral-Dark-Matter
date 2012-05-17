function h = uifigure(varargin)
% Constructor for uifigure object.
%   UIFIGURE(NAME,C1,C2,...) sets the figure node name, and adds
%   optional child objects C1, C2, etc.
%
%   A uifigure node represents an HG figure window.
%
%   Children will be added to the figure in the order specified,
%   and typically include menus, buttons, and a status bar.
%   These components are order-independent.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.12 $ $Date: 2010/01/25 22:47:10 $

% Allow subclass to invoke this directly
h = uimgr.uifigure;

% This object does not support a user-specified widget function;
% the uifigure always instantiates an HG figure.
h.allowWidgetFcnArg = false;

% We always create a figure every time we render
h.WidgetFcn = @(h)createFigure(h);

% Figure always has root (0) as parent
% use graphicalparent, not parent - this makes
% things work well for re-rendering
h.GraphicalParent = 0;

% Continue with standard group instantiation
h.uigroup(varargin{:});

% -----------------------------
function hWidget = createFigure(h)
% Create the HG figure

% By default, we specify the figure name as the node name
%
% Setting the tag name of the toolbar is not essential.
% It is done for possible future use, and to support testing.
%
% 'IntegerHandle,'off' protects against inadvertently deleting handle (e.g.,
% delete(1));
%
hWidget = figure('parent',h.GraphicalParent, ...
    'tag',h.name, ...
    'numbertitle','off', ...
    'menubar','none', ...
    'name',h.name,...
    'IntegerHandle','off');
setappdata(hWidget, 'UIMgr', h);

hCover = uicontrol(hWidget, 'style','text', 'tag', 'coverup');

% Initialize visualization area
% This is simply a bottom-up flow container
%
% Also establish a uicontainer for the statusbar,
% so it "stays put" during unrender/re-render cycles
hMainFlow = uiflowcontainer('v0', ...
    'parent', hWidget, ...
    'flowdirection','bottomup', ...
    'HitTest', 'off', ...
    'margin',.1);

% The following code is commented until we chose to expose the
% handle of the uiflowcontainer to the user in future.

% hg_pkg = findpackage('hg');
% findclass(hg_pkg,'uiflowcontainer');
% schema.prop(h,'hMainFlow','hg.uiflowcontainer');
% h.hMainFlow = hMainFlow;

% Container at bottom of uiflowcontainer for statusbar
hStatusParent = uicontainer('parent',hMainFlow);
schema.prop(h,'hStatusParent','mxArray');
h.hStatusParent = hStatusParent;
set(hStatusParent,'HeightLimits',[0,0]);

setappdata(hCover, 'Position', ...
    uiservices.addlistener(hStatusParent, 'Position', 'PostSet', ...
    @(hSrc, ev) syncCover(hStatusParent, hCover)));

% Container at top of uiflowcontainer for visualizations
hVisParent = uicontainer('parent', hMainFlow, 'HitTest', 'off');
schema.prop(h,'hVisParent','mxArray');
h.hVisParent = hVisParent;

% -------------------------------------------------------------------------
function syncCover(hStatusParent, hCover)

pos = get(hStatusParent, 'Position');

pos = [0 0 pos(3)+pos(1)*2 pos(4)+pos(2)*2];

if pos(3) <= 0 || pos(4) <= 0 || any(isnan(pos)) || any(isinf(pos))
    return;
end

set(hCover, 'Units', get(hStatusParent, 'Units'), ...
    'Position', pos);

% [EOF]
