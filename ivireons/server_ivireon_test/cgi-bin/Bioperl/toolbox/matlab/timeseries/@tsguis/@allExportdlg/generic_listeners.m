function generic_listeners(h)

% Copyright 2004 The MathWorks, Inc.


%% Dialog visibility listener
h.Listeners = [h.Listeners; ...
    handle.listener(h,h.findprop('Visible'),'PropertyPostSet', ...
    @(es,ed) set(h.Figure,'Visible',get(h,'Visible')))];

