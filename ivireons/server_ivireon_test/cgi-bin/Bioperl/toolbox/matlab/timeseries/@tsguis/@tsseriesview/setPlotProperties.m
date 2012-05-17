function status = setPlotProperties(h,ts)

% Copyright 2006 The MathWorks, Inc.

status = true;

%% Initial wave is abs time vector so start with an absolute time vector
if isempty(h.Plot.waves) && ~isempty(ts{1}.TimeInfo.StartDate)
    h.Plot.StartDate = ts{1}.TimeInfo.StartDate;
    h.Plot.TimeUnits = 'days';
    thisDateFormat = ts{1}.TimeInfo.Format;
    if ~isempty(thisDateFormat) && tsIsDateFormat(thisDateFormat)
        h.Plot.TimeFormat = ts{1}.TimeInfo.Format;
    end
elseif length(h.Plot.waves)>=1 &&  isempty(ts{1}.TimeInfo.StartDate)~= isempty(h.Plot.waves(1).DataSrc.Timeseries.TimeInfo.StartDate)
    errordlg('You cannot combine both relative and absolute time series in the same time plot.',...
       'Time Series Tools','modal')
    status = false;
    return
% Relative time vector to absolute plot      
elseif strcmp(h.Plot.Absolutetime,'on') && isempty(ts{1}.TimeInfo.StartDate)
    msg = xlate('You are attempting to add a time series with a relative time vector to a view displaying an absolute time vector. Proceeding will remove any reference to absolute time in the plot.');
    ButtonName = questdlg(msg, 'Time Vector Reference Mismatch', ...
                       'Convert View to Relative Time','Continue','Abort','Abort');
    ButtonName = xlate(ButtonName);              
    if strcmp(ButtonName,xlate('Abort'))
        status = false;
        return
    end
    if strcmp(ButtonName,xlate('Convert View to Relative Time'))
        h.Plot.Startdate = '';
    end
elseif strcmp(h.Plot.Absolutetime,'off') && ~isempty(ts{1}.TimeInfo.StartDate)
    msg = 'You are attempting to add a time series with an absolute time vector to a view which uses a relative time vector so the absolute time cannot be displayed in the view.';
    ButtonName = questdlg(msg, 'Time Vector Reference Mismatch', ...
                       'Continue','Abort','Abort');
    ButtonName = xlate(ButtonName); 
    if strcmp(ButtonName,xlate('Abort'))
        status = false;
        return
    end
end

%% If this is the first time series to be added sets the units/format in the
%% @timeplot to the current timeseries units/format
if isempty(h.Plot.waves) 
   set(h.Plot,'TimeUnits',ts{1}.TimeInfo.Units,...
       'TimeFormat',ts{1}.TimeInfo.Format)
   h.Plot.AxesGrid.XUnits = h.Plot.TimeUnits;
end