function thisrender(hObj, hax)
%THISRENDER Render for the root object.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2008/05/31 23:27:58 $

if nargin < 2,
    hax = gca;
end

if strcmpi(hObj.Current, 'on'),
    props = getcurrentprops(hObj);
else
    props = getdefaultprops(hObj);
end
    
[x, y] = getxy(hObj);

h.line = line(x, y, 'Parent', hax, 'ButtonDownFcn', hObj.ButtonDownFcn, ...
    'Visible', 'Off', 'Tag', class(hObj), ...
    'UIContextMenu', hObj.UIContextMenu, props{:});

% Listen to the Real, Imaginary, Conjugate, Current, ButtonDOwnFcn and
% UIContextMenu properties
l = [ ...
        handle.listener(hObj, ...
        [hObj.findprop('Real') hObj.findprop('Conjugate') hObj.findprop('Imaginary')], ...
        'PropertyPostSet', @newvalue_listener); ...
        handle.listener(hObj, hObj.findprop('Current'), ...
        'PropertyPostSet', @lclcurrent_listener); ...
        handle.listener(hObj, ...
        [hObj.findprop('ButtonDownFcn') hObj.findprop('UIContextMenu')], ...
        'PropertyPostSet', @lclhg_listener); ...
    ];
set(l, 'CallbackTarget', hObj);

setappdata(h.line, 'RootObject', hObj);

set(hObj, 'Handles', h);
set(hObj, 'WhenRenderedListeners', l);
set(hObj, 'FigureHandle', get(hax, 'Parent'));

lclcurrent_listener(hObj);

% ----------------------------------------------------------------
function lclhg_listener(hObj, eventData)

h = get(hObj, 'Handles');

if strcmpi(hObj.Enable, 'On'),
    set(h.line, 'ButtonDownFcn', hObj.ButtonDownFcn, 'UIContextMenu', hObj.UIContextMenu);
end

% ----------------------------------------------------------------
function lclcurrent_listener(hObj, eventData)

if isrendered(hObj),
    
    h = get(hObj, 'Handles');
    if strcmpi(hObj.Current, 'on'),
        props = getcurrentprops(hObj);
    else
        props = getdefaultprops(hObj);
    end
    set(h.line,  props{:});
end

% ----------------------------------------------------------------
function newvalue_listener(hObj, eventData)

if isrendered(hObj), % xxx UDD bug.  listener firing when it doesn't exist on UNDO
    
    h = get(hObj, 'Handles');
    
    [x, y] = getxy(hObj);
    
    set(h.line, 'XData', x, 'YData', y);
end

% ----------------------------------------------------------------
function [x, y] = getxy(hObj)

x = hObj.Real;
y = hObj.Imaginary;

if strcmpi(hObj.Conjugate, 'on'),
    x = [x x];
    y = [y -y];
end
