function modeType = findMoveMode(hThis,pos)
% Finds and sets the current "MoveMode" for the annotation object.

% Copyright 2006 The MathWorks Inc.

% This is a bit of a hack, but efficient. We will set the "HitTest"
% property of all children of the annotation 
hChil = findall(double(hThis));

% Enable the "HitTest" property on the affordances.
hitState = get(hChil(2:end),'HitTest');
set(hChil(2:end),'HitTest','on');

% Find out what we clicked on:
hFig = ancestor(hThis,'Figure');
hObj = handle(hittest(hFig,pos));

% Restore the state of the "HitTest" property:
arrayfun(@set,hChil(2:end),repmat({'HitTest'},size(hChil(2:end))),hitState);

if ~isequal(hObj,hThis) && ~isequal(handle(get(hObj,'Parent')),hThis)
    modeType = 'none';
    hThis.MoveMode = 'none';
    return;
end

% If we clicked on an affordance, its "Tag" is the move type. Otherwise,
% the mode is "mouseover":

modeType = 'mouseover';
if isa(hObj,'hg.line') && ~isempty(get(hObj,'Tag'))
    tagInfo = get(hObj,'Tag');
    switch tagInfo
        case {'topleft','topright','bottomright','bottomleft','bottomright',...
                'left','top','bottom','right'}
            modeType = tagInfo;
    end
end

% Store the "MoveMode" information:
hThis.MoveMode = modeType;