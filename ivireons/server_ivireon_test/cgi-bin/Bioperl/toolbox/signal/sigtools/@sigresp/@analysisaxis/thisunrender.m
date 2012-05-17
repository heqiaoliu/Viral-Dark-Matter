function thisunrender(this)
%THISUNRENDER Unrenders the analysis axis specific stuff.

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2010/05/20 03:10:44 $

if isa(this.OBDListener, 'handle.listener') || isa(this.OBDListener, 'event.listener')
    delete(this.OBDListener);
end

% Make sure that the listeners are deleted so that they do not fire. 
delete(get(this, 'UsesAxes_WhenRenderedListeners'));

hRProps = get(this, 'UsesAxes_RenderedPropHandles');
if isempty(hRProps),
    hRProps = [this.findprop('UsesAxes_WhenRenderedListeners') ...
        this.findprop('UsesAxes_RenderedPropHandles')];
end
delete(hRProps);

h = get(this, 'Handles');
if isfield(h, 'axes'),
        
    % Reset the axes
    h.axes(~ishghandle(h.axes)) = [];
    key = 'graphics_linkaxes';

    for indx = 1:length(h.axes),
        props = {'XGrid', 'YGrid', 'ColorOrder'};
        values = get(h.axes(indx), props);
        reset(h.axes(indx));
        set(h.axes(indx), props, values)
        
        % Remove the linkaxes listener.  We cannot use linkaxes(h, 'off')
        % because it calls drawnow which results in flicker.
        if isappdata(h.axes(indx), key)
            rmappdata(h.axes(indx), key);
        end
    end
    
    % Remove the axes, since we do not want to unrender this.
    set(this, 'Handles', rmfield(h, 'axes'));
end

if isfield(h, 'legend');
    if ishghandle(h.legend)
        delete(getappdata(h.legend, 'OBD_Listener'));
    end
end        

% Replace with super:thisunrender.
delete(handles2vector(this));
% Unrender all the children
for hindx = allchild(this)
    unrender(hindx);
end

objspecificunrender(this);

% [EOF]
