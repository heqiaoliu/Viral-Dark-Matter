function update(cd,r)
%UPDATE  Data update method for @tsMeanData class.

%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $  $Date: 2005/12/15 20:57:23 $

% Compute mean value responses for each of the data objects in the response
% for the defined time interval

if ~isempty(r.Data.Time)
    if isempty(cd.StartTime)
        cd.StartTime = r.Data.Time(1);
    end
    if isempty(cd.EndTime)
        cd.EndTime = r.Data.Time(end);
    end
else
    cd.StartTime = nan;
    cd.EndTime = nan;
end

I = r.Data.Time>=cd.StartTime & r.Data.Time<=cd.EndTime;

data = r.Data.Amplitude;
cd.MeanValue = NaN*zeros([size(data,2) 1]);
cd.StdValue = NaN*zeros([size(data,2) 1]);
cd.MedianValue = NaN*zeros([size(data,2) 1]);
for k=1:size(data,2)
   J = find(~isnan(data(:,k))&I);
   if ~isempty(J)
       cd.MeanValue(k) = mean(data(J,k));
       cd.StdValue(k) = std(data(J,k));
       cd.MedianValue(k) = median(data(J,k));
   else
       cd.MeanValue(k) = NaN;
       cd.StdValue(k) = NaN;
       cd.MedianValue(k) = NaN;
   end
end
 

