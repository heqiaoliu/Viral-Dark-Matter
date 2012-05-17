function sigma(this,r,wspec,type)
%SIGMA   Updates Singular Value data for SIGMA plots.

%  Author(s): Kamesh Subbarao
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:21:37 $

% Note: WSPEC must come first because always assumed to be 3rd input by LTI
% Viewer
nsys = length(r.Data);
NormalRefresh = strncmp(r.RefreshMode,'normal',1);
SysData = getPrivateData(this.Model);
if numel(SysData)~=nsys
   return  % number of models does not match number of data objects
elseif nargin<4
   type = 0;
end

% Get new data from the @ltisource object.
for ct=1:nsys
   % Look for visible+cleared responses in response array
   Ts = SysData(1).Ts;
   if isfinite(SysData(ct)) && ...
         isempty(r.Data(ct).SingularValues) && strcmp(r.View(ct).Visible,'on')
      % Get frequency response data
      d = r.Data(ct);  
      if NormalRefresh
         % Default behavior: regenerate data on appropriate grid based on input arguments
         [sv,w,FocusInfo] = sigmaresp(SysData(ct),type,wspec,true);
         d.Focus = FocusInfo.Focus;
         d.SoftFocus = FocusInfo.Soft;
      else
         % Dynamic update: reuse the current frequency vector for maximum speed
         [sv,w] = sigmaresp(SysData(ct),type,d.Frequency,true);
      end
      % Store in response data object (@sigmadata instance)
      d.Frequency = w;
      d.SingularValues = sv';
      d.Ts = Ts;
   end
end

