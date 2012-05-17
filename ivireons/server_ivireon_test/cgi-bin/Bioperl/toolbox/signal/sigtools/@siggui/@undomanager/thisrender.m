function thisrender(hMgr, hFig, varargin)
%RENDER Render the Undo Manager
%   RENDER(hMGR,hFIG,POS,ITEMPOS) Render the Undo Manager associated with
%   hMGR on the figure hFIG whose menu is associated with POS.  The 'Undo'
%   option will be rendered in the position ITEMPOS and the 'Redo' option
%   will be  rendered in the ITEMPOS + 1 position.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.5 $  $Date: 2007/12/14 15:20:07 $

error(nargchk(2,4,nargin,'struct'));

% If there is already an undomanager installed on the figure, error out.
if sigisappdata(hFig, 'siggui', 'UndoManager') && ...
        isa(siggetappdata(hFig, 'siggui', 'UndoManager'), 'siggui.undomanager'),
    error(generatemsgid('GUIErr'),'There is already an undo manager associated with this figure.');
end

set(hMgr, 'FigureHandle', hFig);

render_menu(hMgr, varargin{:});
render_toolbar(hMgr);

stack_listener(hMgr);

sigsetappdata(hFig, 'siggui', 'undomanager', 'handle', hMgr);

% Install Listeners
attachlisteners(hMgr);


% --------------------------------------------------------------------
function render_menu(hMgr, MenuPos, DepthPos)

hFig = get(hMgr, 'FigureHandle');

cbs  = callbacks(hMgr);

if nargin < 2,
    hedit = findobj(hFig, 'type', 'uimenu', 'tag', 'edit');

    h.undo = findobj(hedit, 'tag', 'undo');
    set(h.undo, 'Callback', {cbs.undo, hMgr});

    h.redo = findobj(hedit, 'tag', 'redo');
    set(h.redo, 'Callback', {cbs.redo, hMgr});
else
    h.undo = addmenu(hFig,[MenuPos DepthPos],'Undo',...
        {cbs.undo, hMgr},'undo','Off','z');
    h.redo = addmenu(hFig,[MenuPos DepthPos+1],'Redo',...
        {cbs.redo, hMgr},'redo','Off','y');
end

set(hMgr,'Handles',h);

% --------------------------------------------------------------------
function render_toolbar(hMgr)

hFig = get(hMgr, 'FigureHandle');
cbs  = callbacks(hMgr);
hut  = findobj(hFig, 'type', 'uitoolbar');
if isempty(hut),
    hut  = uitoolbar(hFig);
    sep  = 'off';
    hunt = [];
    hret = [];
else
    sep = 'on';
    hunt = findobj(hut, 'tag', 'undo');
    hret = findobj(hut, 'tag', 'redo');
end

h = get(hMgr, 'Handles');

bmp = load('mwtoolbaricons');

props = {'tag', 'undo_button', 'ClickedCallback', {cbs.undo, hMgr}};
if isempty(hunt),
    h.undo(2) = uipushtool(hut, ...
        'Enable', 'Off', ...
        'Visible', 'Off', ...
        'Separator', sep, ...
        'CData', bmp.undo);
else
    h.undo(2) = hunt;
end
set(h.undo(2), props{:});

props = {'tag', 'redo_button', 'ClickedCallback', {cbs.redo, hMgr}};
if isempty(hret),
    h.redo(2) = uipushtool(hut, ...
        'Enable', 'Off', ...
        'Visible', 'Off', ...
        'CData', bmp.redo);
else
    h.redo(2) = hret;
end
set(h.redo(2), props{:});

set(hMgr,'Handles',h);

% [EOF]
