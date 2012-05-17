function repin(hThis,point,pinax,pinobj)
% Repin the object to a new point in the axes.

%   Copyright 2006 The MathWorks, Inc.

enableState = get(hThis,'Enable');
set(hThis,'Enable','off');
hFig = ancestor(hThis,'Figure');
l = hThis.Listeners;
% save delete listener & the AxisInvalidateEvent listener
l = [l(1) l(2) l(3) l(4)];

set(hThis,'PinnedObject',pinobj);
pinax = handle(pinax);
set(hThis,'DataAxes',pinax);

figpt = hgconvertunits(hFig,[point 0 0],'pixels',get(hFig,'Units'),0);
figpt = figpt(1:2);
set(hFig,'CurrentPoint',figpt);

% Find where to repin the pin
if ~isempty(pinobj)
    [vint,vert] = vertexpicker(handle(pinobj),'-force');
    if ~isempty(vint)
        vert=vint;
    end
    if length(vert) == 2 %if axes is 2D, set the 3rd coord to zero
        vert(3) = 0.0;
    end
    set(hThis, 'DataPosition', vert);
else
    pt = zeros(3,1);
    ptLine = get(pinax, 'CurrentPoint');
    for i=1:3
        pt(i) = 0.5*(ptLine(1,i) + ptLine(2,i));
    end
    %Make sure that the Z-Coord is zero, if the axis is 2D
    if is2D(pinax)
        pt(3) = 0;
    end
    
    %Set the pin's data/position
    set(hThis, 'DataPosition', [pt(1) pt(2) pt(3)]);
end

% if object add data listeners
if ~isempty(hThis.PinnedObject)
  pinobj = handle(hThis.PinnedObject);
  l(end+1) = handle.listener(pinobj, findprop(pinobj,'XData'), ...
      'PropertyPostSet', {@localChangedPinnedObjData,hThis});
  l(end+1) = handle.listener(pinobj, findprop(pinobj,'YData'), ...
      'PropertyPostSet', {@localChangedPinnedObjData,hThis});
  l(end+1) = handle.listener(pinobj, findprop(pinobj,'ZData'), ...
      'PropertyPostSet', {@localChangedPinnedObjData,hThis});
end

h.Listeners = l;
set(hThis,'Enable',enableState);

%-------------------------------------------------------%
function localChangedPinnedObjData(hProp,eventData,hThis) %#ok<INUSL>

hThis.changedPinnedObjData;