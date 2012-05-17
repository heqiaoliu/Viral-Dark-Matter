function RespData = getUncertainTimeRespData(this, RespType, r, Data, varargin)
% getUncertainTimeRespData Updates time response data for uncertain models
%
%  RESPTYPE = {step, impulse, initial}
%  VARARGIN = {Tfinal or time vector}.

%  Author(s): Craig Buhr
%  Copyright 1986-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:36:28 $
% nsys = length(r.Data.TimeData);
SysData = getUncertainModelData(this);
nsys = length(SysData);
% if numel(SysData)~=nsys
%    return  % number of models does not match number of data objects
% end
NormalRefresh = strncmp(r.RefreshMode,'normal',1);
RefreshFocus = r.RefreshFocus;

% Get initial condition for INITIAL
if strcmp(RespType,'initial')
   varargin = [varargin {r.Parent.Context.IC}];
end

% Get new data from the @ltisource object.
if strcmp(r.View.Visible,'on')
    d = r.Data;
    RespData = Data.Data;
    for ct = 1:nsys
        % Look for visible+cleared responses in response array
        if isfinite(SysData(ct)) %%isempty(r.Data(ct).TimeData.Amplitude) && 
            % Recompute response
            
            Dsys = SysData(ct);
            Ts = Dsys.Ts;
            try
                if NormalRefresh
                    % Regenerate data on appropriate grid based on input arguments
                    [RespData(ct).Amplitude,RespData(ct).Time] = timeresp(Dsys,RespType,varargin{:});
                else
                    % Reuse the current sampling time for maximum speed
                    t = d.Time;
                    if isempty(RefreshFocus) %|| NormalRefresh
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
                    RespData(ct).Time = t(:);
                    RespData(ct).Amplitude = timeresp(Dsys,RespType,t,varargin{2:end});
                end
            end
        end
    end
    Data.Data = RespData;
end


