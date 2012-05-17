function addEvent(h,e)

% Copyright 2006 The MathWorks, Inc.

%% Currently events must have a unique name in the time series
if any(strcmp(e.Name,get(h.Timeseries.Events,{'Name'})))
    errordlg('The names of events within a time series must be unique',...
        'Time Series Tools','modal')
    return
end

%% Add an eevent to the internal time series
h.Timeseries.addevent(e);

%% Create transaction
T = tsguis.transaction;
recorder = tsguis.recorder;

%% Record action
if strcmp(recorder.Recording,'on')
    T.addbuffer('%% Add a new event');
    T.addbuffer(['e = tsdata.event(''' e.Name ''',' sprintf('%f',e.Time) ,');']);
    T.addbuffer(['e.Units = ''' e.Units ''';']);
    if ~isempty(e.StartDate)
         T.addbuffer(['e.StartDate = ''' e.StartDate ''';']);
    end
    T.addbuffer([h.Timeseries.Name ' =  addevent(' h.Timeseries.Name ',e);'],h.Timeseries);
end

% add the timeseries to the transaction object
T.ObjectsCell = {T.ObjectsCell{:}, h.Timeseries}; %r.s.

%% Store transaction
T.commit;
recorder.pushundo(T);