function tsout = vertcat(ts1,ts2,varargin)
%VERTCAT  Overloaded vertical concatenation of time series objects
%
%   TS = VERTCAT(TS1,TS2,...) vertical concatenation performs
%
%         TS = [TS1 ; TS2 ; ...]
% 
%   This operation appends time series objects.  The time vectors must not
%   overlap.  The last time in TS1 must be earlier than the first time in
%   TS2.  The sample size of the time series must agree.    

%   Copyright 2004-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/04/05 22:23:34 $


% Process argument pairwise
if isa(ts2,'timeseries')
    c = classhandle(ts1);
    error('timeseries:vertcat:type','Time series concatenation cannot be performed on a pair of %s.%s object and timeseries object.',...
        c.Package.Name,c.Name)    
end
tsout = localConcat(ts1,ts2);
for k=1:nargin-2
    tsout = localConcat(tsout,varargin{k});
end

function tsout = localConcat(ts1,ts2)

if ~isa(ts1,'timeseries') || ts1.Length==0
    tsout = ts2;
    return
elseif ~isa(ts2,'timeseries') || ts2.Length==0
    tsout = ts1;
    return
end

% Merge time vectors onto a common basis
[ts1timevec, ts2timevec, outprops] = ...
    timemerge(ts1.timeInfo, ts2.timeInfo,ts1.time,ts2.time);

% Concatonate time and ord data.
% both are empty
if isempty(ts1timevec) && isempty(ts2timevec)
    tsout = ts1;
    return
% ts1 is empty
elseif isempty(ts1timevec)
    tsout = ts2;
    return
% ts2 is empty
elseif isempty(ts2timevec)
    tsout = ts1;
    return
% Both are not empty
else
    if ts1timevec(end)>ts2timevec(1) 
        error('timeseries:vertcat:nooverlap',...
            'The time vectors of the specified time series must be consecutive.')
    end
    time = vertcat(ts1timevec,ts2timevec);

    % Build the output data array
    if ~isequal(ts1.getdatasamplesize,ts2.getdatasamplesize)
        error('timeseries:vertcat:errdim',...
            'Data arrays must have the same sample size.')
    end

    % Merge the time alignment
    % Rule: if both of their IsTimeFirst are false, out is false, otherwise, true
    [data1,data2] = tsAlignSizes(ts1.Data, ts1.IsTimeFirst,ts2.Data,ts2.IsTimeFirst);
 

    if ~ts1.IsTimeFirst && ~ts2.IsTimeFirst
        if isequal(size(data1),ts1.getdatasamplesize)
            dataout = cat(ndims(data1)+1,data1,data2);
        elseif isequal(size(data2),ts2.getdatasamplesize)
            dataout = cat(ndims(data2)+1,data1,data2);
        else
            dataout = cat(ndims(data1),data1,data2);
        end
    else    
        dataout = [data1;data2];
    end

    % Build output time series. If both time series are subclasses
    % try to make the output the same classs
    tsout = ts1;
    tsout.dataInfo = cat(ts1.dataInfo,ts2.dataInfo);
    tsout = init(tsout,dataout,time,'IsTimeFirst',ts1.IsTimeFirst || ts2.IsTimeFirst,...
        'Name','unnamed');
    tsout.timeInfo.StartDate = outprops.ref;
    tsout.timeInfo.Units = outprops.outunits;
    tsout.timeInfo.Format = outprops.outformat;

    % Quality arithmatic - merge quality info and combine quality codes
    if ~isempty(ts1.qualityInfo) && ~isempty(ts2.qualityInfo)
        tsout.qualityInfo = qualitymerge(ts1.qualityInfo,ts2.qualityInfo);
    end
    if ~isempty(tsout.qualityInfo) && ~isempty(ts1.quality) && ~isempty(ts2.quality)
        tsout.Quality = [ts1.quality;ts2.quality];
    end

    % Event concat
    tsout.Events = horzcat(ts1.Events,ts2.Events);
end