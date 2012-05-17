function update(cd,r)
%UPDATE  Data update method for @eventCharData class.

%  Author(s):  
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2005/06/27 22:57:37 $

data = r.DataSrc.Timeseries.Data;
cd.MeanValue = NaN*zeros([size(data,2) 1]);
for k=1:size(data,2)
   J = find(~isnan(data(:,k)));
   if ~isempty(J)
       cd.MeanValue(k) = mean(data(J,k));
   else
       cd.MeanValue(k) = NaN;
   end
end