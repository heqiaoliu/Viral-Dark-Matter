function moveDataCursor(hQuiver,hDataCursor,dir)
% Specifies datamarker position on a bar plot behavior when user selects
% arrows keys (up,down,left,right).

% Copyright 2005 The MathWorks, Inc.

% x,y could be a vector or an mxn array
x = get(hQuiver,'XData');
y = get(hQuiver,'YData');
z = get(hQuiver,'ZData');
currind = hDataCursor.DataIndex;
hAxes = ancestor(hQuiver,'hg.axes');

width = size(x,2);
len = size(x,1);
newind = currind;
if strcmpi(dir,'up')
   if currind < numel(x)
      newind = currind + 1;
   end
elseif strcmpi(dir,'right')
   newind = currind + width; 
   if newind > numel(x)
       row = mod(currind,width);
       newRow = row+1;
       newCol = 1;
       newind = len*(newCol-1)+newRow;
   end
elseif strcmpi(dir,'left')
    newind = currind - width;
    if newind < 0
       row = mod(currind,width);
       newRow = row-1;
       newCol = width;
       newind = len*(newCol-1)+newRow;
   end
elseif strcmpi(dir,'down')
   if currind > 1
      newind = currind - 1;
   end
end

% Update vertex position
if newind > 0 && newind <= numel(x)
   hDataCursor.DataIndex = newind;
   if ~isempty(z)
       hDataCursor.Position = [x(newind),y(newind),z(newind)];
	   hDataCursor.TargetPoint = [x(newind),y(newind),z(newind)];
   else
       hDataCursor.Position = [x(newind),y(newind)];
	   hDataCursor.TargetPoint = [x(newind),y(newind)];
   end
end