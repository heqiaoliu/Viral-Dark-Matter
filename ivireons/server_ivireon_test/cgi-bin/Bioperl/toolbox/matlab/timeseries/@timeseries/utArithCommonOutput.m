function tsout = utArithCommonOutput(ts1,ts2,dataout,commomTimeVector,outprops,operator,warningFlag) 
%UTARITHCOMMONOUTPUT
%
 
% Copyright 2006 The MathWorks, Inc.

% Build the output timeseries
tsout = ts1;
if ~ts1.IsTimeFirst && ~ts2.IsTimeFirst
    tsout = init(tsout,dataout,commomTimeVector,'IsTimeFirst',false,'Name','unnamed');
else
    tsout = init(tsout,dataout,commomTimeVector,'IsTimeFirst',true,'Name','unnamed');
end

% Merge timemetadata properties
tsout.timeInfo.StartDate = outprops.ref;
tsout.timeInfo.Units = outprops.outunits;
tsout.timeInfo.Format = outprops.outformat;
% Merge datametadata properties
switch operator
    case '+'
        tsout.dataInfo = plus(ts1.dataInfo,ts2.dataInfo);
    case '-'
        tsout.dataInfo = minus(ts1.dataInfo,ts2.dataInfo);
    case '.*'
        tsout.dataInfo = times(ts1.dataInfo,ts2.dataInfo);
    case '*'
        tsout.dataInfo = mtimes(ts1.dataInfo,ts2.dataInfo);
    case './'
        tsout.dataInfo = rdivide(ts1.dataInfo,ts2.dataInfo);
    case '/'
        tsout.dataInfo = mrdivide(ts1.dataInfo,ts2.dataInfo);
    case '.\'
        tsout.dataInfo = ldivide(ts1.dataInfo,ts2.dataInfo);
    case '\'
        tsout.dataInfo = mldivide(ts1.dataInfo,ts2.dataInfo);
end
% Merge qualmetadata properties
if ~isempty(ts1.qualityInfo) && ~isempty(ts2.qualityInfo)
    tsout.qualityInfo = qualitymerge(ts1.qualityInfo,ts2.qualityInfo);
end
% Merge quality values: pick up minimums
if ~isempty(get(get(tsout,'qualityInfo'),'Code')) && ~isempty(ts1.quality) && ...
        ~isempty(ts2.quality)
    tsout.Quality = min(ts1.quality,ts2.quality);
end
% Merge events
tsout = addevent(tsout,horzcat(ts1.Events,ts2.Events));
% issue a warning if offset is used.
if warningFlag
    warning('timeseries:arith:newtime','The time vector in the new time-series object has been re-generated.')    
end
