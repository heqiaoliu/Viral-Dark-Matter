function updateDataCursor(this,hDataCursor,target)
%UPDATEDATACURSOR Update contour data cursor
  
%   Copyright 1984-2006 The MathWorks, Inc.

% Calculate the closest vertex point 
% from the data field to the mouse selection point (target)

% x,y could be a vector or an mxn array
x = get(this,'XData');
y = get(this,'YData');
isvector_x = isvector(x);
isvector_y = isvector(y);

% Mouse selection point
% In order to take 3-D views into account, we exploit the fact that the
% contour will always have 2-D data (read Z-coordinate is 0). In order to
% find the point of intersection, intersect the target point with the Z=0
% plane.
% We parameterize the target point
% v = t(x1-x2,y1-y2,z1-z2) + (x2,y2,z2)
% And solve for v(3) = 0
t = target(2,3) / (target(2,3) - target(1,3));
v = t*(target(1,:) - target(2,:)) + target(2,:);
xp = v(1);
yp = v(2);

% x,y is a vector, a rectangular grid
if isvector_x && isvector_y
    [val,xind] = min(abs(x-xp));
    [val,yind] = min(abs(y-yp));
    hDataCursor.Position = [x(xind),y(yind)];
    hDataCursor.DataIndex = [xind,yind];
    hDataCursor.TargetPoint = hDataCursor.Position;

% x or y is an array, may not be rectangular
else 
    % Handle unlikely scenario when x is a vector 
    % and y is an array or vice versa. Blow up
    % vector to an array.
    if isvector_x, x = repmat(x,size(y,1),1); end
    if isvector_y, y = repmat(y',1,size(x,1)); end
    
    % Distance from target (mouse point) to each vertex
    d = (x - xp).^2 + (y - yp).^2;
    
    % Closest point is minimum distance
    [val,linear_ind] = min(d(:));
    if ~isempty(linear_ind)
        linear_ind = linear_ind(1); % enforce only one output
        [i1,i2] = ind2sub(size(x),linear_ind);
        hDataCursor.Position = [x(i1,i2),y(i1,i2)];
        hDataCursor.DataIndex = [i1,i2];
        hDataCursor.TargetPoint = hDataCursor.Position;
    else
       error('MATLAB:specgraph:contour:updateDataCursor',...
             'Unable to position data cursor');
    end
end
