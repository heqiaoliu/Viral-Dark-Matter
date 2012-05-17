function C = utTuningFrequencyResponse(Model,Type,Rule)
% Tuning PID based on ultimate frequency and ultimate gain
%   Rules apply to a stable or integrating plant in two steps:
%   1. compute ultimate gain Ku and ultimate frequency Wu
%   2. find Kp Ti Td N based on the specified rule.
%
%   C is returned as a @pidstd object. When designing PID with derivative
%   filter, N is always set to 10. 

%   Author(s): Rong Chen
%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:29:30 $

hw = ctrlMsgUtils.SuspendWarnings;  %#ok<NASGU>
% get Ts
Ts = Model.Ts;
% compute step response
[y t] = step(Model);
% remove offset from direct feed-through term
Offset = y(1);
y = y - Offset;
% compute K
K = evalfr(Model,double(Ts>0));
if isinf(K)
    % get sign of integrating process by the sign of y(end)
    SignOfGain = sign(y(end));
    % calculate maximum slope as K
    y = y*SignOfGain;
    K = (y(end)-y(end-1))/(t(end)-t(end-1));
elseif K~=0
    % get sign of non-integrating process by the sign of dcgain
    SignOfGain = sign(K);
    % get K
    K = y(end)*SignOfGain;
end
if K==0
    ctrlMsgUtils.error('Control:design:PIDTuning12');
end
% compute Wu
result = allmargin(SignOfGain*Model);
if isempty(result.GMFrequency)
    ctrlMsgUtils.error('Control:design:PIDTuning14');
else
    Wu = result.GMFrequency(1);
    Ku = result.GainMargin(1);
    if ~(isfinite(Wu) && isfinite(Ku) && Ku~=0 && Wu~=0)
        ctrlMsgUtils.error('Control:design:PIDTuning14');
    end
end

switch Rule
    case 'zncl'
        C = ut_ZieglerNichols(Type,Ku,Wu);
    case 'amigocl'                
        C = ut_AMIGO(Type,Ku,Wu,K);
end                

%% post-processing
C = C*SignOfGain;
if Ts>0
    C = c2d(C,Ts);
end

    
function C = ut_ZieglerNichols(Type,Ku,Wu)
Tu = 2*pi/Wu;
switch Type
    case 'p'
        C = pidstd(0.5*Ku);
    case 'pi'
        C = pidstd(0.4*Ku,0.8*Tu);
    case 'pid'
        C = pidstd(0.6*Ku,0.5*Tu,0.125*Tu);        
    case 'pidf'
        C = pidstd(0.6*Ku,0.5*Tu,0.125*Tu,10);        
end

function C = ut_AMIGO(Type,Ku,Wu,K)
Kappa = 1/Ku/K;
Tu = 2*pi/Wu;
switch Type
    case 'p' 
        C = pidstd(0.5*Ku);
    case 'pi' 
        C = pidstd(0.16*Ku,Tu/(1+4.5*Kappa));
    case 'pid'
        C = pidstd((0.3-0.1*Kappa^4)*Ku,0.6/(1+2*Kappa)*Tu,0.15*(1-Kappa)/(1-0.95*Kappa)*Tu);
    case 'pidf'
        C = pidstd((0.3-0.1*Kappa^4)*Ku,0.6/(1+2*Kappa)*Tu,0.15*(1-Kappa)/(1-0.95*Kappa)*Tu,10);
end

