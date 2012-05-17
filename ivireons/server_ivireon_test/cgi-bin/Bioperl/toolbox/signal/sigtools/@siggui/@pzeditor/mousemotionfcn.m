function mousemotionfcn(hObj)
%MOUSEMOTIONFCN Fired when the mouse moves

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/01/05 18:00:57 $

% If the callback object does not exist, return.  It was a deleted pz
hcbo = get(hObj, 'CallbackObject');
if ~ishghandle(hcbo), return; end

% Only register motion if we have a left click, the action is set to
% move and we did not click on the axes
hC  = get(hObj, 'CurrentRoots');

if any([~strcmpi(get(hObj, 'ButtonClickType'), 'Left') ...
            ~strcmpi(get(hObj, 'Action'), 'Move Pole/Zero') ...
            strcmpi(get(hcbo, 'Type'), 'axes') ...
            length(hC) ~= 1])
    return
end

cp  = get(hObj, 'CurrentPoint');

setvalue(hC, cp(1)+cp(2)*i);

currentroots_listener(hObj, 'update_currentvalue');

% [EOF]
