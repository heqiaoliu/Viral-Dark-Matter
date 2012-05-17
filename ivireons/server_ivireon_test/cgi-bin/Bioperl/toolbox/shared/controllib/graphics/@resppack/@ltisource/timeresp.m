function timeresp(this, RespType, r, varargin)
% TIMERESP Updates time response data
%
%  RESPTYPE = {step, impulse, initial}
%  VARARGIN = {Tfinal or time vector}.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:49:49 $
nsys = length(r.Data);
SysData = getModelData(this);
if prod(size(SysData))~=nsys
   return  % number of models does not match number of data objects
end
NormalRefresh = strncmp(r.RefreshMode,'normal',1);
RefreshFocus = r.RefreshFocus;

% Get initial condition for INITIAL
if strcmp(RespType,'initial')
   varargin = [varargin {r.Context.IC}];
end

% Get new data from the @ltisource object.
for ct = 1:nsys
   % Look for visible+cleared responses in response array
   if isempty(r.Data(ct).Amplitude) && strcmp(r.View(ct).Visible,'on') && isfinite(SysData(ct))
      % Recompute response
      d = r.Data(ct);
      Dsys = SysData(ct);
      Ts = Dsys.Ts;
      try
         if NormalRefresh
            % Regenerate data on appropriate grid based on input arguments
            [d.Amplitude,d.Time,d.Focus] = timeresp(Dsys,RespType,varargin{:});
            d.Ts = Ts;
         else
            % Reuse the current sampling time for maximum speed
            t = d.Time;
            if isempty(RefreshFocus)
               % Reuse the current time vector.
               % RE: Beware of t(end)=Inf for final value encoding
               lt = length(t);
               t(lt) = t(lt-1) + t(2)-t(1);
            else
               % Use time vector that fills visible X range
               % RE: Used in SISO Tool for max efficiency and visual comfort
               if Ts==0
                  dt = max(RefreshFocus(2)/500,t(2)-t(1));  % 500 points max
               else
                  dt = Ts;
               end
               t = 0:dt:RefreshFocus(2);
            end
            d.Time = t;
            d.Amplitude = timeresp(Dsys,RespType,t,varargin{2:end});
         end
      end
   end
end
