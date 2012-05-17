function updateDataCursor(this,hDataCursor,target)
%UPDATEDATACURSOR Update quiver data cursor
  
%   Copyright 1984-2006 The MathWorks, Inc. 

ch = get(this,'Children');
% We will treat the 2-D and 3-D cases slightly differently as the vertex
% picker is not well-behaved in 2-D where quiver is concerned
if isempty(this.ZData)
    x = get(this,'XData');
    y = get(this,'YData');

    distbase = (target(1,1)-x).^2 + (target(1,2)-y).^2;
    ch = get(this,'Children');
    linex = get(ch(1),'XData');
    liney = get(ch(1),'YData');
    tipx = linex(2:3:end);
    tipy = liney(2:3:end);
    disttip = (target(1,1)-tipx).^2 + (target(1,2)-tipy).^2;

    [basemin,baseind] = min(distbase(:));
    [tipmin,tipind] = min(disttip(:));

    if tipmin < basemin
        hDataCursor.Position = [x(tipind(1)) y(tipind(1))];
        hDataCursor.DataIndex = tipind(1);
    else
        hDataCursor.Position = [x(baseind(1)) y(baseind(1))];
        hDataCursor.DataIndex = baseind(1);
    end
    hDataCursor.TargetPoint = hDataCursor.Position;
else
    % The first child is the base of the quiver group. Call the vertex picker
    % to find out where on the child we are closest. We will always snap to the
    % nearest data point.
    [pout, unused, viout] = vertexpicker(ch(1),target,'-force');
    % Only snap to data vertices that actually represent data.
    diff = mod(viout-1,3);
    linex = get(ch(1),'XData');
    liney = get(ch(1),'YData');
    linez = get(ch(1),'ZData');
    if diff == 2
        viout = viout+1;
    elseif diff == 1
        viout = viout-1;
    end
    pout = [linex(viout) liney(viout) linez(viout)];
    % Translate the point into the index into the quiver plot:
    newInd = fix(viout/3)+1;
    hDataCursor.Position = pout;
    hDataCursor.DataIndex = newInd;
    hDataCursor.TargetPoint = pout;
end