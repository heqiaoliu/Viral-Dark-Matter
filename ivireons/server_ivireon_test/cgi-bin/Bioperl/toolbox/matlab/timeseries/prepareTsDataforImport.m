function status = prepareTsDataforImport(ts,varargin)
%
% tstool utility function
% Check is time series data is fit for imprting into tstool.
%  - Return "failed" status if data is complex.
%  - Make time the first dimension (so that IsTimeFirst is true).
%  - Fold higher dimensions as columns.
%  - Convert non-double data into double.
%  - convert sparse data into full.
%  - Throw error if '/' appears in the name of timeseries.
%  - Scalarize StartTime/EndTime.
%  - Convert Infs into NaNs.
%  - Remove Quality info if quality description is empty.
%  - Reconcile the units of events and timeseries.

% This function should be called by the createTsToolNode methods of
% timeseries, and simulink timeseries, and also by the data replacement
% subroutine of simulinkParentNode/createChild method.

%   Copyright 2005-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.6 $ $Date: 2008/09/13 06:57:23 $

status = true;

% Look for slashes in the name of Timeseries object
I = strfind(ts.Name,'/');
if ~isempty(I)
    error('tstool:invalidsignalname','Slashes (''/'') are not allowed in the names of time series.')
end

% No complex numbers allowed for data
if ~isreal(ts.Data)
    msg = sprintf('Cannot use complex-valued time series within Time Series Tools.\nImport of ''%s'' failed.',...
        ts.Name);
    errordlg(msg, 'Time Series Tools','modal')
    status = false;
    return
end

% No empty names allowed for timeseries name
if isempty(ts.Name) && ~isa(ts,'Simulink.Timeseries') %Simulink Timeseries can have empty names, and they are repopulated..
    msg = sprintf('Cannot use time series with empty names within Time Series Tools.\nImport failed.');
    errordlg(msg, 'Time Series Tools','modal')
    status = false;
    return
end

% Sample-based quality values not allowed, if data is multi-column
szq = size(ts.Quality);
if sum(szq>1)>1
    msg = sprintf('Time series quality must be the same size as the time vector in Time Series Tools.\nImport failed.');
    errordlg(msg, 'Time Series Tools','modal')
    status = false;
    return
end


% check isTimeFirst value and make it true if it is false
if ~ts.IsTimeFirst
    % make transpose
    ts.transpose;
end

% check the size of each sample and return error if the sample size is not
% 1-by-1 or a vector
s = size(ts.Data);
if length(s)>2
    data = reshape(ts.Data,s(1),prod(s(2:end))); %we know Time is first column
    ts.Data = data;
    b_state = warning('query','backtrace');
    warning off backtrace;
    warning('tstool:NDdata',...
        'Time series ''%s'' has data of size [%s].\nThe higher dimensions have been folded in as extra columns in Time Series Tools.',...
        ts.Name,num2str(s))
    warning(b_state);
end

% Check data class and sparseness
if ~isa(ts.Data,'double')
    ts.Data = double(ts.Data);
    b_state = warning('query','backtrace');
    warning off backtrace;
    warning('tstool:nondoubledata',...
        'Data in time series ''%s'' was converted to double.',ts.Name)
    warning(b_state);
end

if issparse(ts.data)
    try
        ts.Data = full(ts.Data);
        b_state = warning('query','backtrace');
        warning off backtrace;
        warning('tstool:sparsedata',...
            'Data in time series ''%s'' was converted from sparse to full.',ts.Name)
        warning(b_state);
    catch me
        disp('Converting sparse data in time series to double...')
        error('tstool:largesparsedata',...
            'Data in time series ''%s'' could not be converted from sparse to full due to the memory limit.',ts.Name)
    end
end

% Check if Start time is  multi-valued (Simulink Time Series could have
% this property for enabled subsystems)
if length(ts.TimeInfo.Start)>1
    % Create new timemetadata with scalar start and end times
    newTimeInfo = Simulink.TimeInfo;
    newTimeInfo = reset(newTimeInfo,ts.Time);
    ts.getContainer('Time').MetaData = newTimeInfo;
    if isnan(newTimeInfo.Increment)
        ts.getContainer('Time').Data = ts.Time;
    end
end

% Check for Inf/-Inf and convert them into NaNs
iInf = isinf(ts.Data);
if sum(iInf(:))>0
    ts.Data(iInf) = NaN;
    b_state = warning('query','backtrace');
    warning off backtrace;
    warning('tstool:infindata',...
        'Infs in time series ''%s'' were converted to NaNs.',ts.Name)
    warning(b_state);
end


% Check for Quality codes with missing description, and remove them 
if ~isempty(ts.Quality) && isempty(ts.QualityInfo.Description)
    ts.Quality = [];
    b_state = warning('query','backtrace');
    warning off backtrace;
    warning('tstool:missingqualitydesc',...
        'Quality information was removed from ''%s'' because no description was found in QualityInfo.',ts.Name)
    warning(b_state);
end

% Reconcile the units of ts.Events with that of ts
if ~isempty(ts.Events) && isa(ts.Events,'tsdata.event')
    tsunits = ts.TimeInfo.Units;
    for k = 1:length(ts.Events)
        evunits = ts.Events(k).Units;
        % backward compatibility
        if isempty(evunits);
            ts.Events(k).Units = 'seconds';
            evunits = 'seconds';
        end
        if ~strcmp(tsunits,evunits)
            ts.Events(k).Units = tsunits; 
            ts.Events(k).Time = ts.Events(k).Time*tsunitconv(tsunits,evunits);
            if isempty(ts.Events(k).StartDate) || isempty(ts.TimeInfo.StartDate)
                ts.Events(k).StartDate = ts.TimeInfo.StartDate;
            end
            b_state = warning('query','backtrace');
            warning off backtrace;
            warning('tstool:eventunitsreconciled',...
                'Units of event ''%s'' were changed to those of time series ''%s''.',...
                 ts.Events(k).Name,ts.Name)
            warning(b_state);
        end
    end
end