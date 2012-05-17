function addTs(h,ts1,ts2)

% Copyright 2004-2008 The MathWorks, Inc.

%% Check that the plot is not too large
if size(ts1.Data,2)*size(ts2.Data,2)>144
    errordlg('Cannot display more than 144 axes. Use the arithmetic expression dialog to reduce the number of columns.',...
        'Time Series Tools','modal')
    return
end

%% New time series require the xlimmode to be in auto to ensure that they
%% can be seen
h.AxesGrid.xlimmode = 'auto';
h.AxesGrid.ylimmode = 'auto';

%% Turn off limit manager and listeners
h.Listeners.setEnabled(false);
h.AxesGrid.LimitManager = 'off';

%% If there is an existing response remove it
rs = h.Responses;
for k=1:length(rs)
    h.rmresponse(rs(k));
end

% Create new tssource
src = tsguis.tssource;
set(src,'Timeseries',ts1,'Timeseries2',ts2);

%% Size the xyplot to match the size of the time series data vectors
[NewOutputNames,NewInputNames] = src.getrcname;
if ts1.TimeInfo.Length~=ts2.TimeInfo.Length
    msg = xlate('Cannot show the correlation plot because the two time series have differing lengths. To view the correlation plot either edit the time series so that they have the same lengths or make another selection.');
    errordlg(msg,'Time Series Tools','modal')
    return
end

resize(h,NewOutputNames,NewInputNames);

%% Make sure all new axes have the right behavior
h.setbehavior

%% Overwrite the axesgrid labels to remove the prefixes 'To:' and
%% 'From:'
set(h.axesgrid,'RowLabel',NewOutputNames,'ColumnLabel',NewInputNames)

% Add the new response
try
    r = h.addresponse(src);
catch 
    return
end
r.datafcn = {@corrresp src r h};
set(r,'Name',sprintf('%s vs. %s',ts1.Name,ts2.Name));

%% Add a listener to each @timeseries datachange event which fires the 
%% waveform datachanged event
r.addlisteners(handle.listener(ts1,'datachange', ...
    {@localDataChange r}));
if ts1~=ts2
    r.addlisteners(handle.listener(ts2,'datachange', ...
            {@localDataChange r}));
end

%% Add a listener to each timeseries name property of the Plot Data
%% to update the axes labeling
r.addlisteners(handle.listener(ts1,ts1.findprop('Name'),'PropertyPostSet',...
    {@localDataChange r}));
if ts1~=ts2
    r.addlisteners(handle.listener(ts2,ts2.findprop('Name'),'PropertyPostSet',...
        {@localDataChange r}));
end

%% Clear row/col labels which have been labelled 'To: Out(1)' and 'From: In(1)'
%% by the addresponse method
[h.axesgrid.rowLabel{:}] = deal('');
[h.axesgrid.columnLabel{:}] = deal('');

%% Update the title to reflect the contents
if length(h.Responses)==1
    if h.Responses.DataSrc.Timeseries == h.Responses.DataSrc.Timeseries2
        h.AxesGrid.Title = sprintf('Autocorrelation: %s', ...
            h.Responses.DataSrc.Timeseries.Name);
    else
        h.AxesGrid.Title = sprintf('Crosscorrelation: %s - %s', ...
            h.Responses.DataSrc.Timeseries.Name,h.Responses.DataSrc.Timeseries2.Name);
    end
end

% Restore xlimmode and limit manager
h.Listeners.setEnabled(true);
h.AxesGrid.LimitManager = 'on';

S = warning('off','all'); % Disable "Some data is missing @resppack warn..."
h.draw
warning(S);



function localDataChange(eventSrc, eventData,r)

%% @timeseries datachange listener callback
S = warning('off','all'); % Disable "Some data is missing @resppack warn..."
r.DataSrc.send('SourceChanged');
%% Update viewnode and viewnodecontainer panels
r.Parent.Parent.send('tschanged')
warning(S);
