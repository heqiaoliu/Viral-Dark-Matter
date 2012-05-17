function generic_listeners(h)

% Copyright 2004-2005 The MathWorks, Inc.

%% Dialog visibility listener
v = tsguis.tsviewer;
h.Listeners = [h.Listeners; ...
    handle.listener(h,h.findprop('Visible'),'PropertyPostSet', ...
    {@localVisibilityCallback h});...
    handle.listener(v.TreeManager.Root,'tsstructurechange',...
        @(es,ed) update(h,[],ed))];

function localVisibilityCallback(es,ed,h)

%% Visibility callback
set(h.Figure,'Visible',get(h,'Visible'))
% Work around a MAC rendering problem where the color
% of the figure remains a light gray native default when the
% figure visibility is turned on by listeners.
if strcmp(computer,'MAC')
    pause(0.2)
end
drawnow


