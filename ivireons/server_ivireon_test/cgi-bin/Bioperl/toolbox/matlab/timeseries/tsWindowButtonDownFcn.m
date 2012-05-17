function tsWindowButtonDownFcn(eventSrc,eventData,h,varargin)
%
% tstool utility function

%   Copyright 2004-2008 The MathWorks, Inc.

%% Switchyard for clicking on axes

%% Set the callbacks
viewer = tsguis.tsviewer;
if strcmp(h.State,'None')
    set(ancestor(h.AxesGrid.Parent,'figure'),'WindowButtonMotionFcn','', ...  
          'WindowButtonUpFcn','')
    if viewer.DataTipsEnabled 
        set(ancestor(h.AxesGrid.Parent,'figure'),'WindowButtonMotionFcn',@hoverfig);
    end
    return
elseif any(strcmp(h.State,{'IntervalSelect','TimeSelect'}))
    set(ancestor(h.AxesGrid.Parent,'figure'),'WindowButtonMotionFcn',{@tsWindowButtonMotionFcn h}, ...  
          'WindowButtonUpFcn',{@tsWindowButtonUpFcn h},...
          'KeyPressFcn',{@tsKeyPressFcn h})
    % Figure must be interruptible for the release to update
    % the current point
    set(h.AxesGrid.Parent,'Interruptible','on')

    % Turn off limit management so that the axestable/tstables on the 
    % viewnode panel do not try to update during a selection
    % TO DO: could come in off already
    h.AxesGrid.LimitManager = 'off';
elseif ~strcmp(h.State,'DataSelect')
    return
end 
switch h.State
    case 'DataSelect'
        % Get the bounds on the selected rectangle
        point1 = get(gca,'CurrentPoint');    % button down detected
        finalRect = rbbox;   
        % $eturn figure units
        point2 = get(gca,'CurrentPoint');    % button up detected
        point1 = point1(1,1:2);              % extract x and y
        point2 = point2(1,1:2);
        p1 = min(point1,point2);             % calculate locations
        offset = abs(point1-point2);         % and dimensions
        x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
        y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
        selected_rect = [point1; point2];
        set(h.axesgrid,'NextPlot','add');
        h.select(gca,selected_rect)
    case 'IntervalSelect'
        % Record the start position
        pt = get(gca,'CurrentPoint');
         
        %% Add selection rectangles to affected waves 
        h.SelectedWaves = [];
        for k=1:length(h.Waves)
            h.Waves(k).View.SelectedInterval = ...
               [h.Waves(k).View.SelectedInterval; pt(1,1) pt(1,1)];
        end  
        
        h.State = 'IntervalSelecting';
    case 'TimeSelect'
        %% Record the start position
        pt = get(gca,'CurrentPoint');
        
        %% Add selection rectanges to affected waves 
        for k=1:length(h.Waves)
            h.Waves(k).View.SelectedTimes = ...
                   [h.Waves(k).View.SelectedTimes; pt(1,1) pt(1,1)];
        end     
        h.State = 'TimeSelecting';
end
 