function update(cd,r)
%UPDATE  Data update method for @TimeFinalValueData class.

%  Author(s): John Glass
%   Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:19:51 $

% Compute final value responses for each of the data objects in the response
DataSrc = r.DataSrc;
if isempty(DataSrc)
   % If there is no source do not give a valid DC gain result.
   cd.FinalValue = NaN(length(r.RowIndex),length(r.ColumnIndex));
else
   % If the response contains a source object compute the final value
   cd.FinalValue = getFinalValue(r.DataSrc,find(r.Data==cd.Parent),r.Context);
end    
