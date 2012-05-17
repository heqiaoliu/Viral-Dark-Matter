function getUncertainMagPhaseData(this, RespType, r, Data, wspec)
%getUncertainMagPhaseData  Updates magnitude and phase data of @magphasedata objects.
%
%  RESPTYPE = 'bode' or 'nichols'

%  Author(s): P. Gahinet, B. Eryilmaz
%   Copyright 1986-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2010/05/10 17:37:36 $
SysData = getUncertainModelData(this);
nsys = length(SysData);
% if numel(SysData)~=nsys
%    return  % number of models does not match number of data objects
% end

NormalRefresh = strncmp(r.RefreshMode,'normal',1);

% Plot-type-specific settings
switch RespType
   case 'bode'
      grade = 3;  
   case 'nichols'
      grade = 2;
end

if strcmp(r.View.Visible,'on')
    d = r.Data;
    RespData = Data.Data;
    % Get new data from the @ltisource object.
    for ct=1:nsys
        % Look for visible+cleared responses in response array
        Ts = SysData(1).Ts;
        if isfinite(SysData(ct))% && isempty(r.Data(ct).Magnitude)
            % Get frequency response data
            if NormalRefresh
                % Default behavior: regenerate data on appropriate grid based on input
                % arguments
                [mag,phase,w,FocusInfo] = freqresp(SysData(ct),grade,wspec,true);
%                 d.Focus = FocusInfo.Focus;
%                 d.SoftFocus = FocusInfo.Soft;
            else
                % Reuse the current frequency vector for maximum speed
                [mag,phase,w] = freqresp(SysData(ct),grade,d.Frequency,true);
            end
            
            % Ignore phase where gain is 0 or Inf (see g144852)
            phase(~isfinite(mag) | mag==0) = NaN;  % phase of 0 or Inf undefined
            
            % Store in response data object (@magphasedata instance)
           RespData(ct).Frequency = w;
           RespData(ct).Magnitude = mag;
           RespData(ct).Phase = phase;
%             d.Ts = Ts;
        end     
    end
    Data.Data = RespData;
end
