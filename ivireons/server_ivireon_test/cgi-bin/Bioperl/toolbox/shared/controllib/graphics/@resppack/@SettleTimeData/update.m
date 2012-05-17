function update(cd,r)
%UPDATE  Data update method @SettleTimeData class

%  Author(s): John Glass
%   Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:18:58 $

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

% Compute Settling Time
t = cd.Parent.Time;
y = cd.Parent.Amplitude;
ns = length(t);
s = lsiminfo(y(1:ns-1,:,:),t(1:ns-1),yf,'SettlingTimeThreshold',cd.SettlingTimeThreshold);

% Store data
cd.Time = reshape(cat(1,s.SettlingTime),nrows,ncols);
cd.FinalValue = yf;

% Compute Y value at settling time
Ysettle = zeros(nrows,ncols);
for ct=1:nrows*ncols
   SettlingTime = cd.Time(ct);
   if isfinite(SettlingTime)
      Ysettle(ct) = utInterp1(t,y(:,ct),SettlingTime);
   else
      Ysettle(ct) = NaN;
   end
end
cd.YSettle = Ysettle;
