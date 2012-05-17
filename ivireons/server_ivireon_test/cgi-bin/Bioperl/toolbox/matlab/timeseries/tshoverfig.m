function tshoverfig(eventSrc,eventData,h,varargin)
%
% tstool utility function

%   Copyright 2004-2006 The MathWorks, Inc.

%% Change mouse shape when it is over the sides of the data panel

% check if mouse is over the edge
if isa(h,'tsexplorer.TreeManager')
    figure_position=get(h.Figure,'Position');
    position=get(h.Figure,'CurrentPoint');
    if position(1)<max(1,h.DialogPosition)+0.5 && position(1)>max(1,h.DialogPosition)-0.5
        set(h.Figure,'Pointer','left');
    elseif position(1)<(figure_position(3)-h.HelpDialogPosition)+0.5 && position(1)>(figure_position(3)-h.HelpDialogPosition)-0.5
        set(h.Figure,'Pointer','left');
    else
        set(h.Figure,'Pointer','arrow');
    end
end