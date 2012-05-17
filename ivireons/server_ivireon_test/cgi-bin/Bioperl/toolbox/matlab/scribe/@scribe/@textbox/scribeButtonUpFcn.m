function res = scribeButtonUpFcn(hThis,point)
% Determine whether we clicked on the text portion of the text arrow, in
% which case we handle the button-up ourselves and put the object into
% "Editing" mode.

res = false;

% Find out what we clicked on:
hFig = ancestor(hThis,'Figure');
point = hgconvertunits(hFig,[point 0 0],'normalized','pixels',hFig);

if ~localCurrentPointInMargin(hThis,point) && strcmpi(get(hFig,'SelectionType'),'open')
    hThis.Editing = 'on';
    res = true;
end

%-------------------------------------------------------%
function isin = localCurrentPointInMargin(hThis,point)
% Find out if the current point is on the margins of the object

isin = false;
hFig = ancestor(hThis,'Figure');

% rectangle center in pixel coords
pos = hgconvertunits(hFig,get(hThis,'Position'),get(hThis,'units'),...
                     'pixels',hFig);
XL = pos(1);
XR = pos(1)+pos(3);
YL = pos(2);
YU = pos(2)+pos(4);

if (point(1)>=XL && point(1)<=XL + hThis.Margin) && ...
   (point(2)>=YL && point(2)<=YU)
   isin=true;
elseif (point(1)<=XR && point(1)>=XR - hThis.Margin) && ...
   (point(2)>=YL && point(2)<=YU)
   isin=true;
elseif (point(2)<=YU && point(2)>=YU - hThis.Margin) && ...
   (point(1)>=XL && point(1)<=XR)
   isin=true;
elseif (point(2)>=YL && point(2)<=YL + hThis.Margin) && ...
   (point(1)>=XL && point(1)<=XR)
   isin=true;
end