function update(cd,r)
%UPDATE  Data update method @StepPeakRespData class

%  Author(s): John Glass
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:19:27 $

% RE: Assumes response data is valid (shorted otherwise)
nrows = length(r.RowIndex);
ncols = length(r.ColumnIndex);

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

% Get data
t = cd.Parent.Time;
y = cd.Parent.Amplitude;
% Skip last sample when not finite
ns = length(t); 
if ~all(isfinite(y(ns,:)))
   t = t(1:ns-1);   y = y(1:ns-1,:,:);
end

% Compute peak abs value and overshoot
if all(isfinite(yf(:)))
   % Stable case
   s = stepinfo(y,t,yf);
   % Store data
   tPeak = reshape(cat(1,s.PeakTime),nrows,ncols);
   cd.OverShoot = reshape(cat(1,s.Overshoot),nrows,ncols);
   % Compute Y value at peak time
   yPeak = zeros(nrows,ncols);
   for ct=1:nrows*ncols
      yPeak(ct) = y(t==tPeak(ct),ct);
   end
else
   % Unstable case: show peak value so far and set overshoot to NaN
   tPeak = zeros(nrows,ncols);
   yPeak = zeros(nrows,ncols);
   for ct=1:nrows*ncols
      [junk,idx] = max(abs(y(:,ct)));
      tPeak(ct) = t(idx);
      yPeak(ct) = y(idx,ct);
   end
   cd.OverShoot = nan(nrows,ncols);
end
      
cd.Time = tPeak;
cd.PeakResponse = yPeak;
