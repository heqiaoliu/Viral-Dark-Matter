function minZ(hThis,hAxes)
%Determine the maximum Z-value in the axes

%   Copyright 1984-2005 The MathWorks, Inc.

if nargin<2
    hAxes = get(hThis,'HostAxes');
end

maxz = -inf;
%Obtain children of the axes whose children may contain Z-data
hLines = findall(hAxes,'Type','line');
hPatches = findall(hAxes,'Type','patch');
hSurfaces = findall(hAxes,'Type','surface');

for iterator = 1:length(hLines)
	vals = get(hLines(iterator),'Zdata');
	maxz = max(maxz,max(vals(:)));
end
for iterator = 1:length(hPatches)
	vals = get(hPatches(iterator),'Zdata');
	maxz = max(maxz,max(vals(:)));
end
for iterator = 1:length(hSurfaces)
	vals = get(hSurfaces(iterator),'Zdata');
	maxz = max(maxz,max(vals(:)));
end

%Define the maximum Z. All datatips should sit above this.
if ~isinf(maxz)
	set(hThis,'ZStackMinimum',maxz+1);
end