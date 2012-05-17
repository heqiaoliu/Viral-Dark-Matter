function updateTarget(hThis)
% Signal to the pinned object that it should update itself given that the
% pin has detected a change in the environment.

%   Copyright 2006 The MathWorks, Inc.

if strcmpi(hThis.Enable,'on')
    % We must operate on all peer pins:
    hPeers = hThis.Target.Pin;
    pinState = get(hPeers,'UpdateInProgress');
    if ~iscell(pinState)
        pinState = {pinState};
    end
    set(hPeers,'UpdateInProgress',true);
    scribeax = graph2dhelper('findScribeLayer',ancestor(hThis,'figure'));
    if ishandle(scribeax)
        invalidateaxis(double(scribeax));
    end

    h = hThis.Target;
    if ~isempty(h) && ishandle(h) && isa(h,'scribe.scribeobject')
        h.updatePositionFromPin(hThis);
    end
    arrayfun(@(obj,val)(set(obj,{'UpdateInProgress'},val)),double(hPeers),pinState);
end