function default_updateDataCursor(hThis,hgObject,hDataCursor,target)
% Determines position and index on object from mouse position

% Copyright 2002-2006 The MathWorks, Inc.

pos = [];
[p,v,ind,pfactor] = vertexpicker(hgObject,target,'-force');
if strcmp(hDataCursor.Interpolate,'on')
   pos = p;
else
   pos = v;
    %If the axes limits are such that the data tip would not be visible,
    %switch to interpolated mode. We only do this for lines
    if isa(handle(hgObject),'hg.line')
        inBounds = localDoClip(hgObject,pos);
        xData = get(hgObject,'XData');
        yData = get(hgObject,'YData');
        zData = get(hgObject,'ZData');
        nextInd = ind + sign(pfactor);
        nextPos(1) = xData(nextInd);
        nextPos(2) = yData(nextInd);
        if ~isempty(zData)
            nextPos(3) = zData(nextInd);
        end
        nextInBounds = localDoClip(hgObject,nextPos);
        if ~inBounds && ~nextInBounds
            set(hDataCursor,'Interpolate','on');
            pos = p;
        end
    end
end
if isa(handle(hgObject),'hg.line')
   hDataCursor.InterpolationFactor = pfactor;
else
   hDataCursor.InterpolationFactor = [];
end
hDataCursor.Position = pos;
hDataCursor.DataIndex = ind;

if isa(hgObject,'hg.surface') || isa(hgObject,'hg.patch') || isa(hgObject,'hg.line')
    if isempty(get(hgObject,'Zdata'))
        hDataCursor.TargetPoint = pos(1:2);
    else
        hDataCursor.TargetPoint = pos;
    end
else
    hDataCursor.TargetPoint = pos;
end

%------------------------------------------------------------%
function inBounds = localDoClip(hgObject,pos)

% See if the cursor position is empty or outside the 
% axis limits
hAxes = ancestor(hgObject,'Axes');
inBounds = false;
xlm = get(hAxes,'xlim'); ylm = get(hAxes,'ylim'); zlm = get(hAxes,'zlim');
if ~isempty(pos) && ...
    pos(1) >= min(xlm) && pos(1) <= max(xlm) && ...
    pos(2) >= min(ylm) && pos(2) <= max(ylm)
    if length(pos) > 2 
        if is2D(hAxes) || (pos(3) >= min(zlm) && pos(3) <= max(zlm))
           inBounds = true;
        end
    else
         inBounds = true;
    end
end