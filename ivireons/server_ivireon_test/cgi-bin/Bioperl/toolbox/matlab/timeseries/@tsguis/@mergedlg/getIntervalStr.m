function [startStr,endStr] = getIntervalStr(h,tsList,method)

% Copyright 2005 The MathWorks, Inc.

%% Generate strings for start and end times of merged time series in the
%% list tsSelected

%% NO-op
if isempty(tsList)
   maxStart = 'Empty time vector';
   minEnd = 'Empty time vector';
   return
end

%% Initialize vars and reset the absTimeFlag is the selection contains a 
%% relative time series    
maxStart = -inf;
minEnd = inf;
absTimeFlag = strcmp(h.ViewNode.getPlotTimeProp('AbsoluteTime'),'on');
% Invalidate absTimeFlag if nore or more selected time series are relative
for k=1:length(tsList)
    if isempty(tsList{k}.TimeInfo.StartDate)
        absTimeFlag = false;
    end
end

%% Merge the time vectors
if strcmp(method,'union')
        for k=1:length(tsList)
            thists = tsList{k};
            if absTimeFlag 
                outunits = 'days';                   
                unitconv1 = tsunitconv(outunits,thists.TimeInfo.Units);
                startTime = thists.TimeInfo.Start*unitconv1+datenum(thists.TimeInfo.StartDate);
                endTime = thists.TimeInfo.End*unitconv1+datenum(thists.TimeInfo.StartDate);
            else
                outunits = h.ViewNode.getPlotTimeProp('TimeUnits');
                unitconv1 = tsunitconv(outunits,thists.TimeInfo.Units);
                startTime = thists.TimeInfo.Start*unitconv1;
                endTime = thists.TimeInfo.End*unitconv1;
            end               
            maxStart = max(startTime,maxStart);
            minEnd = min(endTime,minEnd);               
        end
        if maxStart>minEnd
            startStr = 'Empty time vector';
            endStr = 'Empty time vector';
        else
            startStr = localParseTimeStr(maxStart,absTimeFlag,outunits);
            endStr = localParseTimeStr(minEnd,absTimeFlag,outunits);
        end            
elseif strcmp(method,'intersection')
        thists = tsList{1};
        if absTimeFlag   
             outunits = 'days';
             unitconv1 = tsunitconv('days',thists.TimeInfo.Units);
             commontimes = thists.Time*unitconv1+datenum(thists.TimeInfo.StartDate);
             for k=2:length(tsList)
                 thists = tsList{k};
                 unitconv1 = tsunitconv('days',thists.TimeInfo.Units);
                 commontimes = intersect(commontimes,...
                    thists.Time*unitconv1+datenum(thists.TimeInfo.StartDate));
             end
         else
             outunits = h.ViewNode.getPlotTimeProp('TimeUnits');
             unitconv1 = tsunitconv(outunits,thists.TimeInfo.Units);
             commontimes = thists.Time;
             for k=2:length(tsList)
                 thists = tsList{k};
                 unitconv1 = tsunitconv(outunits,thists.TimeInfo.Units);
                 commontimes = intersect(commontimes,thists.Time*unitconv1);
             end
         end
         if isempty(commontimes)
              startStr = 'Empty time vector';
              endStr = 'Empty time vector';
         else 
             startStr = localParseTimeStr(commontimes(1),absTimeFlag,outunits);
             endStr = localParseTimeStr(commontimes(end),absTimeFlag,outunits);
         end
elseif strcmp(method,'uniform')
         minStart = inf;
         maxStart = -inf;
         minEnd = inf;
         maxEnd = -inf;
         for k=1:length(tsList)
             thists = tsList{k};  
             if absTimeFlag
                outunits = 'days';
                unitconv = tsunitconv('days',thists.TimeInfo.Units);
                thisStart = unitconv*thists.TimeInfo.Start+datenum(thists.TimeInfo.StartDate);
                thisEnd = unitconv*thists.TimeInfo.End+datenum(thists.TimeInfo.StartDate);

             else  % Convert start-end to timeplot units
                outunits = h.ViewNode.getPlotTimeProp('TimeUnits');
                unitconv = tsunitconv(outunits,thists.TimeInfo.Units);
                thisStart = thists.TimeInfo.Start*unitconv;
                thisEnd = thists.TimeInfo.End*unitconv;
             end
             minStart = min(minStart,thisStart);
             maxStart = max(maxStart,thisStart);
             minEnd = min(minEnd,thisEnd);
             maxEnd = min(minEnd,thisEnd);
         end
         if maxStart<minStart
             startStr = 'Empty time vector';
         else
             startStr = localParseTimeStr([minStart maxStart],absTimeFlag,outunits);
         end
         if maxEnd<minEnd
             endStr = 'Empty time vector';
         else
             endStr = localParseTimeStr([minEnd maxEnd],absTimeFlag,outunits);
         end                        
end

function outStr = localParseTimeStr(timeVal,absTimeFlag,outunits)

if absTimeFlag
    if isscalar(timeVal) || timeVal(1)==timeVal(end)
        outStr = datestr(timeVal(1));
    else
        outStr = sprintf('%s - %s',datestr(timeVal(1)),datestr(timeVal(end)));
    end
else
    if isscalar(timeVal) || timeVal(1)==timeVal(end)
        outStr = sprintf('%0.3g %s',timeVal(1),outunits);
    else
        outStr = sprintf('%0.3g - %0.3g %s',timeVal(1),timeVal(end),outunits);
    end
end