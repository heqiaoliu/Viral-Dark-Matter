function res = scribeButtonUpFcn(hThis,point)
% Determine whether we clicked on the text portion of the text arrow, in
% which case we handle the button-up ourselves and put the object into
% "Editing" mode.

%   Copyright 2006 The MathWorks, Inc.

res = false;

% Enable the "HitTest" property on the affordances.
hChil = findall(double(hThis));
hitState = get(hChil(2:end),'HitTest');
set(hChil(2:end),'HitTest','on');

% Find out what we clicked on:
hFig = ancestor(hThis,'Figure');
point = hgconvertunits(hFig,[point 0 0],'normalized',get(hFig,'Units'),hFig);
point = point(1:2);
hObj = handle(hittest(hFig,point));

% Restore the state of the "HitTest" property:
arrayfun(@set,hChil(2:end),repmat({'HitTest'},size(hChil(2:end))),hitState);

if isa(hObj,'hg.text') && strcmpi(get(hFig,'SelectionType'),'open')
    hThis.Editing = 'on';
    res = true;
end