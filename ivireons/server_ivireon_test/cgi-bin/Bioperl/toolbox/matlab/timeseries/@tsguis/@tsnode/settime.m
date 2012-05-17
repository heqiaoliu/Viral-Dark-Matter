function settime(h,t,varargin)

% Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $ $Date: 2006/06/27 23:11:55 $

%% Method to set the time vector of the internal time series to a value
%% which may be different from its currrent length. Used by the "Apply"
%% button on the @tsnode panel to reset the time vector. Additional
%% arguments are units and startdatenum

if isempty(h.Timeseries) || h.Timeseries.TimeInfo.Length==0
    return
end

%% Create transaction
T = tsguis.transaction;
T.ObjectsCell = {T.ObjectsCell{:}, h.Timeseries};
recorder = tsguis.recorder;

%% Update @timemetadata
if nargin>=5 %% Format
    h.Timeseries.TimeInfo.Format = varargin{3};
    % Data recording
    if strcmp(recorder.Recording,'on')
        T.addbuffer([h.Timeseries.Name, '.TimeInfo.Format = ''', varargin{3},...
            ''';']);
    end
end
if nargin>=3 % Time units
    h.Timeseries.TimeInfo.Units = varargin{1};
    % must keep events units in-sync with timeseries units in the GUI if
    % this is a relative time series
    if ~isempty(h.Timeseries.Events)
        for k = 1:length(h.Timeseries.Events)
            % For abs time keep event time constant
            if ~isempty(h.Timeseries.TimeInfo.StartDate)
                h.Timeseries.Events(k).Time = h.Timeseries.Events(k).Time*...
                    tsunitconv(varargin{1},h.Timeseries.Events(k).Units);
            end
            h.Timeseries.Events(k).Units = varargin{1};
        end     
    end
    % Data recording
    if strcmp(recorder.Recording,'on')
        T.addbuffer([h.Timeseries.Name '.TimeInfo.Units = ''' varargin{1} ''';']);
        T.addbuffer('%% Update event units to match the timeseries time units.');
        if ~isempty(h.Timeseries.Events)
            T.addbuffer(['for n = 1:length(',h.Timeseries.Name,'.Events)']);
            if ~isempty(h.Timeseries.TimeInfo.StartDate)
                T.addbuffer(['    ','convFact = tsunitconv(''',varargin{1}, ''',', ...
                    h.Timeseries.Name '.Events(n).Units);']);
                T.addbuffer(['    ',h.Timeseries.Name '.Events(n).Time = ',...
                    h.Timeseries.Name,'.Events(n).Time*convFact;']);
            end
            T.addbuffer(['    ',h.Timeseries.Name '.Events(n).Units = ''' varargin{1} ''';']);
            T.addbuffer('end');
        end
    end
end
ed = [];
if nargin>=4 % Start date
    % Changing time modes drops events
    if (~isempty(varargin{2}) && isempty(h.Timeseries.TimeInfo.StartDate)) || ...
            (isempty(varargin{2}) && ~isempty(h.Timeseries.TimeInfo.StartDate))
        
        % Check that this timeseries is not plotted
        viewerH = tsguis.tsviewer;
        if viewerH.isTimeseriesViewed(h)
            error('tsnode:settime:plotformerr',...
                xlate('Cannot change the absolute relative status of a time series which appears in one or more plots.'));
        end
        
        % Drop events
        h.Timeseries.Events = [];
        ed = tsdata.dataChangeEvent(h.Timeseries,'formatchange',[]);
        if strcmp(recorder.Recording,'on')
            T.addbuffer('%% Clear events when modifying to absolute time');
            T.addbuffer([h.Timeseries.Name '.Events = [];']);
        end
    end
    h.Timeseries.TimeInfo.StartDate = varargin{2};

    % Data recording
    if strcmp(recorder.Recording,'on')
        T.addbuffer([h.Timeseries.Name '.TimeInfo.StartDate = ''' varargin{2} ''';']); 
    end
else
    if ~isempty(h.Timeseries.TimeInfo.StartDate) % Changing time modes drops events
        ed = tsdata.dataChangeEvent(h.Timeseries,'formatchange',[]);
        h.Timeseries.Events = [];
        if strcmp(recorder.Recording,'on')
            T.addbuffer('%% Clear events when modifying to relative time');
            T.addbuffer([h.Timeseries.Name '.Events = [];']);
        end
    end
    h.Timeseries.TimeInfo.StartDate = '';
    % Data recording
    if strcmp(recorder.Recording,'on')
        T.addbuffer([h.Timeseries.Name '.TimeInfo.StartDate = '''';']);
    end
end


%% Update the time vector
dataChangeEnable = h.Timeseries.DataChangeEventsEnabled;
h.Timeseries.DataChangeEventsEnabled = false;

try
    h.Timeseries.Time = t;
    h.Timeseries.DataChangeEventsEnabled = dataChangeEnable;
    if isempty(ed)
        h.Timeseries.fireDataChangeEvent;
    else
        h.Timeseries.fireDataChangeEvent(ed);
    end
catch
    h.Timeseries.DataChangeEventsEnabled = dataChangeEnable;
end    
if strcmp(recorder.Recording,'on')
    T.addbuffer(['tsTime = linspace(' sprintf('%f',t(1)) ',' ...
        sprintf('%f',t(end)) ','  sprintf('%d',length(t)) ')'';'])
    T.addbuffer([h.Timeseries.Name '.Time = tsTime;'],h.Timeseries);
end 


%% Store transaction
T.commit;
recorder.pushundo(T);