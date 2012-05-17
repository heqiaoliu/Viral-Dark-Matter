function draw(this, allroots)
%DRAW Draw the pole/zero plot

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $  $Date: 2008/08/22 20:33:16 $

if ~isrendered(this),
    error(generatemsgid('notRendered'), ...
        'The DRAW method cannot be used when the PZEditor is not rendered.');
end

updatelimits(this);

h = get(this, 'Handles');

if nargin < 2,
    
    delete(findall(h.axes, 'tag', 'sigaxes.pole'));
    delete(findall(h.axes, 'tag', 'sigaxes.zero'));
    
    allroots = get(this, 'AllRoots');
    if ~isempty(allroots)
        allroots = [allroots.roots];
    end
end

visState = get(this, 'Visible');

if ~isempty(allroots),
        
    % Set up their buttondown functions
    set(allroots, 'UIContextMenu', h.contextmenu.action, ...
        'ButtonDownFcn', {@buttondown_cb, this});
    
    for indx = 1:length(allroots),
        render(allroots(indx), h.axes);
    end
    set(allroots, 'Visible', visState);
end

updatenumbers(this);

if nargin < 2,
    currentsection_listener(this);
end

% ---------------------------------------------------------
function buttondown_cb(hcbo, eventstruct, h)

abstract_buttondownfcn(h, hcbo);

% ---------------------------------------------------
function lclChangePtr(hcbo, eventStruct, this)

hfig = gcbf;
p    = getptr(hfig);

ptr = '';
switch lower(get(this, 'Action'))
case 'movepz'
    switch lower(get(hcbo, 'tag')),
    case {'pole', 'zero'}
        ptr = 'hand';
    case 'pzeditor_axes'
        ptr = 'crosshair';
    end
case {'addpole', 'addzero'}
    ptr = lower(get(this, 'Action'));
case 'deletepz'
    ptr = 'eraser';
end

if ~isempty(ptr),
    setptr(hfig, ptr);
    setappdata(hcbo, 'MouseExitedFcn', {@lclChangePtrBack, p});
end

% ---------------------------------------------------
function lclChangePtrBack(hcbo, eventStruct, p)

hfig = gcbf;
set(hfig, p{:});

% [EOF]
