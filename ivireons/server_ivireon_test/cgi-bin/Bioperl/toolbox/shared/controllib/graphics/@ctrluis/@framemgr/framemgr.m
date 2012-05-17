function h = framemgr(Frame)
% Returns instance of @framemgr class

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:16:27 $

h = ctrluis.framemgr;
h.Frame = Frame;

% Add listeners
h.Listeners = [...
        handle.listener(h,h.findprop('SelectedContainer'),...
        'PropertyPreSet',{@LocalClear h}) ; ...
        handle.listener(h,h.findprop('Status'),...
        'PropertyPostSet',{@LocalShowStatus h})];
        

%--------------- Local functions -----------------------------

function LocalClear(eventSrc,eventData,h)
h.clearselect;

function LocalShowStatus(eventSrc,eventData,h)
h.poststatus(eventData.NewValue);