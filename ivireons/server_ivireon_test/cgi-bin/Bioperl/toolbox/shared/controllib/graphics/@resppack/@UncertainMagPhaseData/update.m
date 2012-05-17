function update(this,r)
%UPDATE  Data update method @UncertainTimeData class

%   Author(s): Craig Buhr
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/05/10 17:37:23 $

% RE: Assumes response data is valid (shorted otherwise)
nrows = length(r.RowIndex);
ncols = length(r.ColumnIndex);

% Compute uncertain responses
if isempty(r.DataSrc)% || ~isUncertain(r.DataSrc)
   % If there is no source do not give a valid yf gain result.
   % Set Data to NaNs
   this.Ts = r.DataSrc.Ts;
   %yf = NaN(nrows,ncols);
else
   % If the response contains a source object compute the uncertain
   % Responses
   %t = this.Parent.Time(1:end-1);
   %getUncertainTimeRespData(r.DataSrc,'step',r,this,t);
   getUncertainMagPhaseData(r.DataSrc,'bode',r,this,[]);
   
end  

