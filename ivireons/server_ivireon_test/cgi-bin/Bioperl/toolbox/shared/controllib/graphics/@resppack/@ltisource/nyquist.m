function nyquist(this, r, wspec)
%NYQUIST  Updates frequency response data.

%  Author(s): P. Gahinet, B. Eryilmaz
%   Copyright 1986-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:49:47 $
nsys = length(r.Data);
SysData = getPrivateData(this.Model);
if numel(SysData)~=nsys
   return  % number of models does not match number of data objects
end
NormalRefresh = strncmp(r.RefreshMode,'normal',1);

% Get new data from the @ltisource object.
for ct=1:nsys
   % Look for visible+cleared responses in response array
   if isfinite(SysData(ct)) && ...
         isempty(r.Data(ct).Response) && strcmp(r.View(ct).Visible,'on')
      % Get frequency response data
      d = r.Data(ct);  
      if NormalRefresh
         % Default behavior: regenerate data on appropriate grid based on input
         % arguments
         [mag,phase,w,FocusInfo] = freqresp(SysData(ct),1,wspec,true);
         d.Focus = FocusInfo.Focus;
         d.SoftFocus = FocusInfo.Soft;
      else
         % Reuse the current frequency vector for maximum speed
         [mag,phase,w] = freqresp(SysData(ct),1,d.Frequency,true);
      end
      % Store in response data object (@magphasedata instance)
      d.Frequency = w;
      d.Response = mag .* exp(1i*phase);
      d.Ts = SysData(ct).Ts;
   end
end
