function status = prepareTsDataforImport(ts,varargin)
%Check is time series data is fit for imprting into tstool.
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

%   Author(s): Rajiv Singh
%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $ $Date: 2009/10/24 19:19:42 $

status = true;

% Look for slashes in the name of Timeseries object
I = strfind(ts.tsValue.Name,'/');
if ~isempty(I)
    error('tstool:invalidsignalname','Slashes (''/'') are not allowed in the names of time series.')
end

% No complex numbers allowed for data
if ~isreal(ts.tsValue.Data)
    msg = sprintf('Cannot use complex-valued time series within Time Series Tools.\nImport of ''%s'' failed.',...
        ts.tsValue.Name);
    errordlg(msg, 'Time Series Tools','modal')
    status = false;
    return
end

%% No empty names allowed for timeseries name
if isempty(ts.tsValue.Name) && ~isa(ts.tsValue,'Simulink.Timeseries') %Simulink Timeseries can have empty names, and they are repopulated..
    msg = sprintf('Cannot use time series with empty names within Time Series Tools.\nImport failed.');
    errordlg(msg, 'Time Series Tools','modal')
    status = false;
    return
end

% Sample-based quality values not allowed, if data is multi-column
szq = size(ts.tsValue.Quality);
if sum(szq>1)>1
    msg = sprintf('Time series quality must be the same size as the time vector in Time Series Tools.\nImport failed.');
    errordlg(msg, 'Time Series Tools','modal')
    status = false;
    return
end


% check isTimeFirst value and make it true if it is false
if ~ts.tsValue.IsTimeFirst
    swarn = warning('off','timeseries:ctranspose:dep_ctrans');
    ts.tsValue = ts.tsValue.transpose;
    warning(swarn);
end

% check the size of each sample and return error if the sample size is not
% 1-by-1 or a vector
s = size(ts.tsValue.Data);
if length(s)>2 
    data = reshape(ts.tsValue.Data,s(1),prod(s(2:end))); %we know Time is first column
    ts.tsValue.Data = data;
    b_state = warning('query','backtrace');
    warning off backtrace;
    warning('tstool:NDdata',...
        'Time series ''%s'' has data of size [%s].\nThe higher dimensions have been folded in as extra columns in Time Series Tools.',...
        ts.Name,num2str(s))
    warning(b_state);
end

% Check data class and sparseness
if ~isa(ts.tsValue.Data,'double')
    ts.tsValue.Data = double(ts.tsValue.Data);
    b_state = warning('query','backtrace');
    warning off backtrace;
    warning('tstool:nondoubledata',...
        'Data in time series ''%s'' was converted to double.',ts.Name)
    warning(b_state);
end

if issparse(ts.tsValue.data)
    try
        ts.tsValue.Data = full(ts.tsValue.Data);
        b_state = warning('query','backtrace');
        warning off backtrace;
        warning('tstool:sparsedata',...
            'Data in time series ''%s'' was converted from sparse to full.',ts.Name) 
        warning(b_state);
    catch me
        disp('Converting sparse data in time series to double...')
        error('tstool:largesparsedata',...
            'Data in time series ''%s'' could not be converted from sparse to full due to the memory limit.',...
            ts.Name)
    end
end

% Check for Inf/-Inf and convert them into NaNs
iInf = isinf(ts.tsValue.Data);
if sum(iInf(:))>0
    ts.tsValue.Data(iInf) = NaN;
    b_state = warning('query','backtrace');
    warning off backtrace;
    warning('tstool:infindata',...
        'Infs in time series ''%s'' were converted to NaNs.',...
        ts.tsValue.Name)
    warning(b_state);
end


% Check for Quality codes with missing description, and remove them 
if ~isempty(ts.tsValue.Quality) && ...
        isempty(ts.tsValue.QualityInfo.Description)
    ts.Quality = [];
    b_state = warning('query','backtrace');
    warning off backtrace;
    warning('tstool:missingqualitydesc',...
        'Quality information was removed from ''%s'' because no description was found in QualityInfo.',...
        ts.tsValue.Name)
    warning(b_state);
end

% Reconcile the units of ts.Events with that of ts
if ~isempty(ts.tsValue.Events) && isa(ts.tsValue.Events,'tsdata.event')
    tsunits = ts.tsValue.TimeInfo.Units;
    for k = 1:length(ts.tsValue.Events)
        evunits = ts.tsValue.Events(k).Units;
        % backward compatibility
        if isempty(evunits);
            ts.tsValue.Events(k).Units = 'seconds';
            evunits = 'seconds';
        end
        if ~strcmp(tsunits,evunits)
            ts.tsValue.Events(k).Units = tsunits; 
            ts.tsValue.Events(k).Time = ...
                ts.tsValue.Events(k).Time*tsunitconv(tsunits,evunits);
            if isempty(ts.tsValue.Events(k).StartDate) || ...
                    isempty(ts.tsValue.TimeInfo.StartDate)
                ts.tsValue.Events(k).StartDate = ...
                    ts.tsValue.TimeInfo.StartDate;
            end
            b_state = warning('query','backtrace');
            warning off backtrace;
            warning('tstool:eventunitsreconciled',...
                'Units of event ''%s'' were changed to those of time series ''%s''.',...
                ts.tsValue.Events(k).Name,ts.tsValue.Name)
            warning(b_state);
        end
    end
end
