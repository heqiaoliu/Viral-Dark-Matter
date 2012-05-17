function settime(h,t,varargin)
%% Method to set the time vector of tscollection to a value
%% which may be different from its currrent length. Used by the "Apply"
%% button on the @tscollectionNode panel to reset the time vector.
%% Additional arguments are units and startdatenum.

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2006/06/27 23:11:43 $

if isempty(h.Tscollection) || h.Tscollection.TimeInfo.Length==0
    return
end


%% Create transaction
T = tsguis.transaction;
T.ObjectsCell = {T.ObjectsCell{:}, h.Tscollection};
recorder = tsguis.recorder;

%% Update @timemetadata
if nargin>=5 %% Format
    h.Tscollection.TimeInfo.Format = varargin{3};
    % Data recording
    if strcmp(recorder.Recording,'on')
        T.addbuffer([h.Tscollection.Name, '.TimeInfo.Format = ''', varargin{3},...
            ''';']);
    end
end
if nargin>=3 % Time units
    h.Tscollection.TimeInfo.Units = varargin{1};
    % Data recording
    if strcmp(recorder.Recording,'on')
        T.addbuffer([h.Tscollection.Name '.TimeInfo.Units = ''' varargin{1} ''';']); 
    end
end
if nargin>=4 % Start date
    % Changing time modes drops timeseries members events
    if (~isempty(varargin{2}) && isempty(h.Tscollection.TimeInfo.StartDate)) || ...
            (isempty(varargin{2}) && ~isempty(h.Tscollection.TimeInfo.StartDate))
        
        % Check that this timeseries is not plotted
        viewerH = tsguis.tsviewer;
        if viewerH.isTimeseriesViewed(h)
            error('tscollectionNode:settime:plotformerr',...
                xlate('Cannot change the absolute relative status of a time series which appears in one or more plots.'));
        end
        
        % Drop events
        tslist = h.Tscollection.gettimeseriesnames;
        for r = 1:length(tslist)
            h.Tscollection.TsValue.(tslist{r}).Events = [];
            if strcmp(recorder.Recording,'on')
                T.addbuffer([h.Tscollection.Name '.' tslist{r}.Name '.Events = [];']);
            end
        end
    end
    h.Tscollection.TimeInfo.StartDate = varargin{2};

    % Data recording
    if strcmp(recorder.Recording,'on')
        T.addbuffer([h.Tscollection.Name '.TimeInfo.StartDate = ''' varargin{2} ''';']); 
    end
else
    if ~isempty(h.Tscollection.TimeInfo.StartDate) % Changing time modes drops events
        tslist = h.Tscollection.gettimeseriesnames;
        for r = 1:length(tslist)
            h.Tscollection.TsValue.(tslist{r}).Events = [];
        end
        h.Tscollection.Events = [];
    end
    h.Tscollection.TimeInfo.StartDate = '';
    % Data recording
    if strcmp(recorder.Recording,'on')
        T.addbuffer([h.Tscollection.Name '.TimeInfo.StartDate = '''';']);
    end
end

%% Update the time vector
if isequal(h.Tscollection.Time,t)
    h.Tscollection.send('datachange');
else
    h.Tscollection.Time = t; %would fire datachange
end

if strcmp(recorder.Recording,'on')
    T.addbuffer(['tsTime = [' sprintf('%f',t(1)) ':' ...
        sprintf('%f',t(2)-t(1)) ':' sprintf('%f',t(end)) ']'';']);
    T.addbuffer([h.Tscollection.Name '.Time = tsTime;'],h.Tscollection);
end 


%% Store transaction
T.commit;
recorder.pushundo(T);