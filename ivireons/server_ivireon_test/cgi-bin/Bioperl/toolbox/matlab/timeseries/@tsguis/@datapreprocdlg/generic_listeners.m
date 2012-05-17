function generic_listeners(h)

% Copyright 2005 The MathWorks, Inc.

%% Dialog visibility listener
h.Listeners = [h.Listeners; ...
    handle.listener(h,h.findprop('Visible'),'PropertyPostSet', ...
    {@localVisibilityCallback h})];

function localVisibilityCallback(es,ed,h)

%% Visibility callback
set(h.Figure,'Visible',get(h,'Visible'))