function generic_listeners(h)

% Copyright 2004-2005 The MathWorks, Inc.

%% Visibility listener
Lvis = handle.listener(h,h.findprop('Visible'),'PropertyPostSet',...
    {@localVisCallback h});

%% Time series node listeners
Lnodechange = [handle.listener(h.Srcnode,'tsstructurechange',...
                 @(es,ed) updatets(h,ed)); ...
               handle.listener(h.Srcnode,'timeserieschange',...
                 @(es,ed) updatets(h,ed))];

h.Listeners = [Lvis; Lnodechange];
h.updatets;

function localVisCallback(es,ed,h)

set(get(h,'Figure'),'Visible',get(h,'Visible'));
% Work around a MAC rendering problem where the color
% of the figure remains a light gray native default when the
% figure visibility is turned on by listeners.
if strcmp(computer,'MAC')
    pause(0.2)
end