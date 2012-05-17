function update(cd,r)
%UPDATE  Data update method for @eventCharData class.

%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.5 $  $Date: 2005/12/15 20:56:00 $

%% Check the event times have not changed (c.f. change of events to values)
ind = find(strcmp(cd.EventName,get(r.DataSrc.TimeSeries.Events,{'Name'})));
if ~isempty(ind)
    thisEvent = r.DataSrc.TimeSeries.Events(ind(1));
    if strcmp(r.Parent.absolutetime,'on') && ~isempty(r.Parent.StartDate)
          cd.Time = (datenum(thisEvent.getTimeStr)-datenum(r.Parent.Startdate))*...
               tsunitconv(r.Parent.TimeUnits,'days');       
    else 
         cd.Time = thisEvent.Time*tsunitconv(r.Parent.TimeUnits,...
             r.DataSrc.TimeSeries.TimeInfo.Units);
    end
    if size(cd.Parent.Amplitude,2)>=2
        ind  = find(~any(isnan(cd.Parent.Amplitude)')');
    else
        ind = find(~isnan(cd.Parent.Amplitude));
    end
    
    if length(ind)>1
        try % interp1 may fail if cd.Parent.Time(ind) has repeated elements
            cd.Amplitude = interp1(cd.Parent.Time(ind),cd.Parent.Amplitude(ind,:),cd.Time);
        catch
            cd.Amplitude = NaN(1,size(cd.Parent.Amplitude,2));
        end
    elseif length(ind)==1
        cd.Amplitude = cd.Parent.Amplitude(ind,:);   
    else
        cd.Amplitude = NaN(1,size(cd.Parent.Amplitude,2));
    end
end

