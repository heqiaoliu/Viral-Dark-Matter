function scale(h,point,mode)

% Copyright 2004-2006 The MathWorks, Inc.

%% Moves the selected waveform to the point "point" through a
%% stretch depending on the initial state of the drag as captured in
%% the structure contrianed in the SelectionStruct property

centroid = h.SelectionStruct.Centroid;
if strcmp(mode,'motion')
    % Capture the initial centroid and scaling params
    
    ydata = h.SelectionStruct.Selectedwave.Data.Amplitude;
    v = (point(2)-centroid)/(h.SelectionStruct.HoverPoint(2)-centroid);
    h.SelectionStruct.HoverPoint(2) = point(2);

    %% Modify the amplitude property without affecting the timeseries
    %% so that the transaction object is able to capture the complete scale once
    %% the buttonup event occurs
    h.SelectionStruct.Selectedwave.Data.Amplitude = (ydata-centroid)*v+centroid;

    %% Refresh - call draw on each wave to avoid triggering a viewchnage
    for k=1:length(h.waves)
        h.waves(k).RefreshMode = 'quick';
        h.waves(k).draw;
    end

    drawnow expose
elseif strcmp(mode,'complete')
    % Get the transaction and recorder handles
    T = tsguis.transaction;
    recorder = tsguis.recorder;
    
    % Get the timeseries
    thists = h.SelectionStruct.Selectedwave.DataSrc.Timeseries;

    % Find the scale factor and offset
    if abs(h.SelectionStruct.StartPoint(2)-centroid)>eps(centroid)
        SF = (point(2)-centroid)/(h.SelectionStruct.StartPoint(2)-centroid);
    else 
        SF = 1;
    end    
    offset = -centroid*SF+centroid;
    
    %% If the recorder is on cache the M code in the transaction buffer
    if strcmp(recorder.Recording,'on')
        T.addbuffer(xlate('%% Time series rescaling'));
        T.addbuffer(sprintf('%s.Data = %s.Data*(%f)+%f;', thists.Name,thists.Name,...
            SF,offset),thists);
    end

    %% During the drag all time series updates were routed to the @timedata
    %% Amplitlitude and Time, update the timeseries with these new values
    T.ObjectsCell = {T.ObjectsCell{:}, thists};
    set(h.SelectionStruct.Selectedwave.DataSrc.Timeseries,'Data',...
        h.SelectionStruct.Selectedwave.DataSrc.Timeseries.Data*SF+offset)

    %% Clear old selections
    for k=1:length(h.Waves)
        set(h.Waves(k).View.Curves,'Selected','off')
    end

    %% Store transaction and clear watermark
    T.commit;
    recorder.pushundo(T);

    %% reset the refresh mode
    h.SelectionStruct.Selectedwave.RefreshMode = 'normal';

    %% Reset the selection struct and the mouse pointer
    h.SelectionStruct = struct('Selectedwave',[],'StartPoint',[],...
        'Centroid',[]);
end
