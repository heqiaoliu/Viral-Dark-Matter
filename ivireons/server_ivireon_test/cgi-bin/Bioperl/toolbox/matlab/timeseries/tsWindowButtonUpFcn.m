function tsWindowButtonUpFcn(eventSrc, eventData, h)
%
% tstool utility function

%   Copyright 2004-2006 The MathWorks, Inc.

if strcmp(h.State,'None')
    h.Parent.shiftAxes([],[],'complete')
    set(ancestor(h.AxesGrid.Parent,'Figure'),'Pointer','arrow')
    set(h.allwaves,'RefreshMode','normal');
elseif (strcmp(h.State,'TimeseriesScaling') || strcmp(h.State,'TimeseriesTranslating')) ...
        && ~isempty(h.SelectionStruct.StartPoint)   
    % Reset the state so that another time series can be selected
    pt = get(gca,'CurrentPoint');
    if strcmp(h.State,'TimeseriesScaling')
        h.State = 'TimeseriesScale';
        h.scale(pt(1,1:2)','complete')
    elseif strcmp(h.State,'TimeseriesTranslating')
        h.State = 'TimeseriesTranslate';
        h.move(pt(1,1:2)','complete')
    end    
    set(ancestor(h.AxesGrid.Parent,'Figure'),'Pointer','arrow')
elseif strcmp(h.State,'IntervalSelecting')
    h.State = 'IntervalSelect';
    set(h.waves,'RefreshMode','normal');
    h.draw
elseif strcmp(h.State,'TimeSelecting')
    h.State = 'TimeSelect';
    set(h.waves,'RefreshMode','normal');
    h.draw
end
set(ancestor(h.AxesGrid.Parent,'figure'),'WindowButtonMotionFcn','', ... 
          'WindowButtonUpFcn','')
    
%% Turn limit manager back on
h.AxesGrid.LimitManager = 'on';
h.AxesGrid.send('ViewChange')
