function yf = getFinalValue(PID,RespType,varargin)
% Computes steady-state value for a given response type.

%   Author(s): Rong Chen
%   Copyright 2009 MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:47:18 $

if strcmpi(RespType,'impulse')
    % convert to internal parameterization
    [~, I] = utGetPIDT(PID);
    % YF is DC gain of s * H(s) or (z-1) * H(z)
    Ts = PID.Ts;
    if Ts==0
        yf = I;
    else
        yf = I * abs(Ts);
    end    
else
    % Compute final value
    yf = dcgain(PID);
end

