function tsLineButtonDown(eventSrc, eventData, h)
%
% tstool utility function

%   Copyright 2004-2008 The MathWorks, Inc.

%% Switchyard for clicking on axes

%% Set the callbacks
if any(strcmp(h.State,{'TimeseriesScale','TimeseriesTranslate','None'}))
    set(ancestor(h.AxesGrid.Parent,'figure'),'WindowButtonMotionFcn',{@tsWindowButtonMotionFcn h}, ...  
          'WindowButtonUpFcn',{@tsWindowButtonUpFcn h},...
          'KeyPressFcn',{@tsKeyPressFcn h})
else % Other states are handled by tsWindowButtonDown
    tsWindowButtonDownFcn(eventSrc,eventData,h)
    return
end


%% Figure must be interruptible for the release to update
%% the current point
set(h.AxesGrid.Parent,'Interruptible','on')

%% Turn off limit management so that the axestable/tstables on the 
%% viewnode panel do not try to update during a selection
%% TO DO: could come in off already
h.AxesGrid.LimitManager = 'off';

switch h.State
    % Timeseries selected for scaling/translation    
    case {'TimeseriesScale','TimeseriesTranslate','None'}
        % Create the selection structure for the selected line
        if strcmp(h.State,'TimeseriesScale')
            for k=1:length(h.Waves)
                if any(eventSrc == h.Waves(k).View.Curves)
                    set(h.Waves(k).View.Curves,'Selected','on',...
                        'markerFaceColor','r');
                    h.SelectionStruct.Selectedwave = h.Waves(k);
                end
            end
            h.State = 'TimeseriesScaling';
            % For rescaling, record the centroid which will be preserved
            h.SelectionStruct.Centroid = ...
               tsnanmean(tsnanmean(h.SelectionStruct.Selectedwave.Data.Amplitude));  
        elseif strcmp(h.State,'TimeseriesTranslate')
            for k=1:length(h.Waves)
                if any(eventSrc == h.Waves(k).View.Curves)
                    set(h.Waves(k).View.Curves,'Selected','on',...
                        'markerFaceColor','r');
                    h.SelectionStruct.Selectedwave = h.Waves(k);
                end
            end
            h.State = 'TimeseriesTranslating';
            % Arrowpressed status must be false to allow mouse translation
            h.SelectionStruct.Arrowpressed = false;
        elseif strcmp(h.State,'None')    
            % For axes reassignment, record the selected axes and line
            for k=1:length(h.Waves)
                ind  = find(eventSrc == h.Waves(k).View.Curves);
                if ~isempty(ind)
                    set(eventSrc,'Selected','on');
                    h.SelectionStruct.Selectedwave = h.Waves(k);
                    h.SelectionStruct.Selectedline = ind(1);
                    h.SelectionStruct.Selectedaxes = ancestor(eventSrc,'Axes');
                    break
                end
            end
        end
        
        % For translation, scaling, axes reassignment, record the start position
        pt = get(gca,'CurrentPoint');
        h.SelectionStruct.StartPoint = pt(1,1:2)';
        h.SelectionStruct.HoverPoint = pt(1,1:2)';

        % Customize the cursor
        set(ancestor(h.AxesGrid.Parent,'Figure'),'Pointer','fleur')
        
        % Set the watermark
        h.SelectionStruct.Selectedwave.Data.setwatermark;
        
end