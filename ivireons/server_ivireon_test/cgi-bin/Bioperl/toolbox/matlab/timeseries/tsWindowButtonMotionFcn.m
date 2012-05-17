function tsWindowButtonMotionFcn(eventSrc, eventData, h)
%
% tstool utility function

%   Copyright 2004-2006 The MathWorks, Inc.

%% Only take action if a time series has been selected and a starting point
%% recorded

if (strcmp(h.State,'TimeseriesScaling') || strcmp(h.State,'TimeseriesTranslating')) ...
        && (~isfield(h.SelectionStruct,'Arrowpressed') || ~h.SelectionStruct.Arrowpressed) ...
        && ~isempty(h.SelectionStruct.StartPoint)               
    %% Get the current point
    pt = get(gca,'CurrentPoint');  
    point = pt(1,1:2);
    
    %% Move/scale the selected time series
    if strcmp(h.State,'TimeseriesTranslating')
        h.move(point,'motion')
    elseif strcmp(h.State,'TimeseriesScaling')
        h.scale(point,'motion')
    end
elseif strcmp(h.State,'IntervalSelecting')
    %% Get the current point
    pt = get(gca,'CurrentPoint');  
    point = pt(1,1:2);
    
    % For each selected wave update the last selection interval
    for k=1:length(h.Waves)
        if ~isempty(h.Waves(k).View.SelectedInterval)
            h.Waves(k).View.SelectedInterval(end,:) = ...
                [h.Waves(k).View.SelectedInterval(end,1),pt(1,1)];
        else
            thisview.SelectedInterval = [pt(1,1) pt(1,1)];
        end
    end  
    
    % Refresh - call draw on each wave to avoid triggering a viewchnage
    for k=1:length(h.waves)
       % Disabled due to background rendering prob h.waves(k).RefreshMode = 'quick';
       h.waves(k).draw;
    end 
    drawnow expose
    
elseif strcmp(h.State,'TimeSelecting')
    %% Get the current point
    pt = get(gca,'CurrentPoint');  
    point = pt(1,1:2);
    
    % For each selected wave update the last selection interval
    for k=1:length(h.Waves)
        if ~isempty(h.Waves(k).View.SelectedTimes)
            h.Waves(k).View.SelectedTimes(end,:) = [h.Waves(k).View.SelectedTimes(end,1), ...
                pt(1,1)];
        else
            thisview.SelectedTimes = [pt(1,1) pt(1,1)];
        end
    end  
    
    % Refresh - call draw on each wave to avoid triggering a viewchnage
    for k=1:length(h.waves)
       % Disabled due to background rendering prob h.waves(k).RefreshMode = 'quick';
       h.waves(k).draw;
    end
    
    drawnow expose
elseif strcmp(h.State,'None')
    ax = ancestor(hittest(eventSrc),'Axes');
    % If hovering over an axes, move the selected line to the current mouse
    % position
    if ~isempty(ax) && strcmp(get(ax,'visible'),'on') && ~strcmp(get(ax,'Tag'),'legend')
        pt = get(ax,'CurrentPoint');  
        h.Parent.shiftAxes(ax,pt(1,1:2),'motion') 
    % If hovering over the lower figure border, create a new axes and move
    % the selected line into it
    else       
        thispt = hgconvertunits(eventSrc,[0 0 get(eventSrc,'currentPoint')],...
            get(eventSrc,'Units'),'normalized',eventSrc);
        axpos = h.AxesGrid.Position;
        if thispt(4)<axpos(2)          
            h.Parent.shiftAxes([],[],'motion')
            % Clear mode after creating a new axes
            tsWindowButtonUpFcn([],[],h)
        end
    end
%     viewer = tsguis.tsviewer;
%     if viewer.DataTipsEnabled
%        hoverfig(eventSrc, eventData);
%     end
end