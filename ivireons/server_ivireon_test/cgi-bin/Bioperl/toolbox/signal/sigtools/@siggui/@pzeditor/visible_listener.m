function visible_listener(this, eventData)
%VISIBLE_LISTENER Listener to the Visible Property

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $  $Date: 2009/02/13 15:14:01 $

h = get(this, 'Handles');

visState = get(this, 'Visible');

% Make the tools menu ('Pole/Zero Editor') enable state match the visible
% state.  don't make it invisible.
set(allchild(h.tools), 'Visible', visState)

if strcmpi(this.CoordinateMode, 'polar'),
    set(h.angleunits, 'Visible', visState);
else
    set(h.angleunits, 'Visible', 'Off');
end

errorStatus = this.ErrorStatus;
if isempty(errorStatus)
    
    set(h.errorstatus, 'Visible', 'off');
    
    allHandles = convert2vector(rmfield(h, ...
        {'angleunits', 'tools', 'contextmenu', 'errorstatus'}));
    set(allHandles, 'Visible', visState);
    
    rootVisState = visState;
else
    set(h.axes, 'Visible', 'off');
    set(h.xlabel, 'Visible', 'off');
    set(h.ylabel, 'Visible', 'off');
    
    allHandles = convert2vector(rmfield(h, ...
        {'angleunits', 'tools', 'contextmenu', 'axes', 'xlabel', 'ylabel'}));
    set(allHandles, 'Visible', visState);
    rootVisState = 'off';
end

z = zoom(this.FigureHandle);
zoomEnab = z.Enable;
z.Enable = 'off';
if strcmpi(visState, 'Off'),
    set(this.FigureHandle, 'KeyPressFcn', []);
else
    cbs = callbacks(this);
    set(this.FigureHandle, 'KeyPressFcn', {cbs.keypress, this});
end
z.Enable = zoomEnab;

allroots = get(this, 'AllRoots');
if ~isempty(allroots)
    allroots = [allroots.roots];
    
    set(allroots, 'Visible', rootVisState);
end

set(h.tools, 'Enable', visState);

% [EOF]
