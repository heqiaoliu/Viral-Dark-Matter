function out = setspectype(hObj, out)
%SETSPECTYPE Set the spec type

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/05/18 02:30:13 $

p = get(hObj, 'DynamicSpec');
l = get(hObj, 'DynamicSpecListener');

% Delete the spec listener
if ~isempty(l), delete(l); end

% Delete the property and cache its value
if isempty(p),
    v = '10000';
else
    v = get(hObj, p.Name);
    delete(p);
end

% Determine what the new property should be called.
switch lower(out)
case 'cutoff',
    name = 'Fc';
case 'passedge',
    name = 'Fpass';
case 'stopedge',
    name = 'Fstop';
end

% Create the new prop and use the cached value
p = schema.prop(hObj, name, 'string');
set(hObj, 'DynamicSpec', p);
set(hObj, name, v);

% Create a new listener on this property
l = handle.listener(hObj, p, 'PropertyPostSet', @lclsetGUIvals);
set(l, 'CallbackTarget', hObj);
set(hObj, 'DynamicSpecListener', l);

% --------------------------------------------------------------
function lclsetGUIvals(hObj, eventData)
% lclsetGUIvals, we must create this listener whenever the dynamic spec
% changes, but we only want the listener to fire when the frame is
% rendered.  This is done by wrapping the setGUIvals call with a call to
% isrendered.

if isrendered(hObj),
    setGUIvals(hObj, eventData);
end

% [EOF]
