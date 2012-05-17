function updateDataCursor(this,hDataCursor,target)

% Copyright 2004-2006 The MathWorks, Inc.

[p,v,ind,pfactor,face,faceiout] = vertexpicker(get(this,'Children'),target,'-force'); 
set(hDataCursor,'Position',v);


% The vertex-picker is not capable of finding the data index for a scatter
% group as it is implemented as a collection of patches. For this reason,
% the returned data index will always be 1. As a post-processing step,
% obtain the data index given the position and the data.
xData = get(this,'XData');
yData = get(this,'YData');
zData = get(this,'ZData');
if ~isempty(zData)
    ind = find((xData == v(1)) & (yData == v(2)) & (zData == v(3)));
    hDataCursor.TargetPoint = [v(1) v(2) v(3)];
else
    ind = find((xData == v(1)) & (yData == v(2)));
    hDataCursor.TargetPoint = [v(1) v(2)];
end
% Force a unique data index
ind = ind(1);
set(hDataCursor,'DataIndex',ind);