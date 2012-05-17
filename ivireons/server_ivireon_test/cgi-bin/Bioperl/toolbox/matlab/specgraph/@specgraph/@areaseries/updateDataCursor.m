function updateDataCursor(this,hDataCursor,target)

% Copyright 2003-2006 The MathWorks, Inc.

% An area object consists of a patch
hPatch = handle(get(this,'children'));
% Find out where on the patch we clicked:
[p,v,ind,pfactor] = vertexpicker(hPatch,target,'-force');

% Find the closest data index to the vertex selected:
if ind > length(this.xdata)+1
  hDataCursor.DataIndex = 2*(1+length(this.xdata)) - ind;
elseif ind ~= 1
  hDataCursor.DataIndex = ind-1;
else
  hDataCursor.DataIndex = 1;
end

% Update v based on recomputed indices
ind = hDataCursor.DataIndex;
v = [hPatch.XData(ind+1);hPatch.YData(ind+1)];

hDataCursor.Position = v;
hDataCursor.TargetPoint = v.';
hDataCursor.InterpolationFactor = [];