function update(cd,r)
%UPDATE  Data update method @StepRiseTimeData class

%   Author(s): John Glass
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:19:33 $

% RE: Assumes response data is valid (shorted otherwise)
nrows = length(r.RowIndex);
ncols = length(r.ColumnIndex);
RiseTimeLims = cd.RiseTimeLimits;

% Get final value
if isempty(r.DataSrc)
   % If there is no source do not give a valid yf gain result.
   yf = NaN(nrows,ncols);
else
   % If the response contains a source object compute the final value
   idxModel = find(r.Data==cd.Parent);
   yf = getFinalValue(r.DataSrc,idxModel,r.Context);
   if isnan(isstable(r.DataSrc,idxModel)) && ~isSettling(r.Data(idxModel),yf)
      % System with delay-dependent dynamics and unsettled response: skip
      yf(:) = Inf;
   end
end  

% Compute rise time data
t = cd.Parent.Time;
y = cd.Parent.Amplitude;
ns = length(t);
[s,xt] = stepinfo(y(1:ns-1,:,:),t(1:ns-1),yf,'RiseTimeLimits',RiseTimeLims);

% Store data
cd.TLow = reshape(cat(1,xt.RiseTimeLow),nrows,ncols);
cd.THigh = reshape(cat(1,xt.RiseTimeHigh),nrows,ncols);

% Compute YHigh = upper rise time target
y0 = reshape(y(1,:),nrows,ncols);
cd.Amplitude = y0 + RiseTimeLims(2)*(yf-y0);
