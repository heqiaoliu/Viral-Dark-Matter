function tsKeyPressFcn(eventSrc, eventData, h, varargin)

% Copyright 2004-2005 The MathWorks, Inc.

%% Switchyard for reacting to key presses

%% ctrl-z undo last transaction
recorder = tsguis.recorder;
if strcmp(eventData.Key,'z') && isequal(eventData.Modifier,{'control'})
    recorder.undo;
end

%% Select data depending on the state of the @waveplot 
if isempty(h.State) || ~ischar(h.State)
    return
end
switch h.State
    case 'DataSelect' 
        %% Delete key callback replaces selected data by NaN
        if ~strcmp(eventData.Key,'delete')
            return
        end
        
        %% Delete selected points
        h.delselection
        
    case 'TimeseriesTranslate'  
        
        %% Is it a valid key
        if ~any(strcmp(eventData.Key,{'uparrow','downarrow','leftarrow',...
                'rightarrow'}))
            return
        end
        
        %% Prevent mouse translations 
        h.SelectionStruct.Arrowpressed = true;
        
        %% Get data
        data = h.SelectionStruct.Selectedwave.Data.Amplitude;
        time = h.SelectionStruct.Selectedwave.Data.Time;
        xlim = h.axesGrid.getylim{1};
        ylim = h.axesGrid.getylim{1};
        
        %% Get the arrow direction
        if strcmp(eventData.Key,'uparrow')
            delta = 0.01*diff(h.axesGrid.getylim{1});
            deltat = 0;
        elseif strcmp(eventData.Key,'downarrow')    
            delta = -0.01*diff(h.axesGrid.getylim{1});
            deltat = 0;
        elseif strcmp(eventData.Key,'leftarrow')    
            deltat = -0.01*diff(h.axesGrid.getxlim{1});
            delta = 0;
        elseif strcmp(eventData.Key,'rightarrow')    
            deltat = 0.01*diff(h.axesGrid.getxlim{1});
            delta = 0;
        end
        
        %% Move the time series up or down. Initial point is the mean of
        %% the first sample
        row = 1;
        col = 1;
        pointY = tsnanmean(data(1,:));
        while isnan(pointY) && row<size(data,1)
            row = row+1;
            pointY = tsnanmean(data(row,:));
        end
        if isnan(pointY)
            return
        end
        point = [time(row)+deltat; pointY+delta];
        h.SelectionStruct.StartPoint = [time(row); pointY];
        h.SelectionStruct.HoverPoint = h.SelectionStruct.StartPoint;
        %% Create transaction and set watermark      
        h.move(point,'motion');  
        h.move(point,'keyrelease'); 
        %% Flush the keyPress queue so that the key up will be processed
        %% right away
        drawnow
        
    case 'IntervalSelect'
         %% Delete key callback filters out selected intervals
        if ~strcmp(eventData.Key,'delete')
            return
        end       
        
        switch class(h)
            case 'tsguis.specplot'
                h.filter
            case 'tsguis.histplot'
                h.delselection
        end

    case 'TimeSelect'
         %% Delete key callback filters out selected intervals
        if ~strcmp(eventData.Key,'delete')
            return
        end               
        
        %% Remove selection - this method handles transaction management
        h.delselection
         
end

