function [c, Kp, Ki, Kd, N] = utPID_ZNOpenLoop(Model,Type,Target,Nin)
% Ziegler-Nichols Open Loop Tuning (Step Response Method)
%   This heuristic PID design method applies to stable plant only.  
%   The method contains three steps:
%       1. generate a step response, which is called process reaction curve
%       2. approximate it with a FOPTD model K/(T*s+1)*e^(-L*s)
%       3. find Kp Ki and Kd based on Chein-Hrones-Reswick (CHR) rules
%
% Note: 
%   1.  for a discrete plant, PID is obtained by discretizing a continuous PID controller
%   2.  for a PID design, when N is empty it is computed as 10*Kp/Kd 
%   3.  when the model has little or zero time delay, e.g. L<<T, the model
%       is approximated by FOP and a pole placement method is used instead

%   Author(s): Rong Chen
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2008/12/04 22:21:23 $

%% ----------------------------------------------------------------
% Step1: obtain step response curve
[y,t] = step(Model);
StepInfo = stepinfo(y,t,'RiseTimeLimits',[0.05 0.7],'SettlingTimeThreshold',0.01);

%% ----------------------------------------------------------------
% Step2.1: calculate T which is the rise time from 5% to 70%
T = StepInfo.RiseTime;
% if T is invalid, return
if isnan(T) || T==0
    ctrlMsgUtils.error('Control:design:PIDTuning11');
end

%% ----------------------------------------------------------------
% Step2.2: calculate K which is evalfr(p,0) - evalfr(p,inf)
% remove direct feed through path from the step response
y = y - y(1);
% get K
if abs(getTs(Model))>0
    K = evalfr(Model,exp(0*1i))-y(1);
else
    K = evalfr(Model,0)-y(1);
end
% if K is invalid, return
if K==0
    ctrlMsgUtils.error('Control:design:PIDTuning12');
end
% if negative gain, convert it into positive for controller design, at the
% end of design, change back the sign of the controller gain accordingly
SignOfGain = sign(K);
y = y*SignOfGain;
K = K*SignOfGain;

%% ----------------------------------------------------------------
% Step2.3: calculate L which is the intercept of the tangent to the step
% response that has the largest slope with the time axis 
[junk,ind] = max(diff(y));
% calculate slope
slope = (y(ind+1)-y(ind))/(t(ind+1)-t(ind));
% if L is invalid, return
if slope==0
    ctrlMsgUtils.error('Control:design:PIDTuning13');
end
% calculate alpha (Section 4.3, Astrom and Hagglund, 1994, 2nd Edition)
alpha = slope*t(ind+1)-y(ind+1); 
% calculate L (Section 4.3, Astrom and Hagglund, 1994, 2nd Edition)
L = alpha/slope;

%% ----------------------------------------------------------------
% Step 3: generate Kc, Ti and Td
% initialize them first
Kc = []; Ti = []; Td = [];
% When the model has little or zero time delay, e.g. L<<T, the model
% is approximated by FOP, Z-N open loop method does not apply.  A pole
% placement method for FOP is used instead to generate PID parameters
% (Section 4.7, Astrom and Hagglund, 1994, 2nd Edition) 
RATIO_L_TAU = 1e-4;
if abs(L/T)<RATIO_L_TAU
    % default pole placement design criteria:
    damping = 0.707;
    w0 = 6/StepInfo.SettlingTime;
    switch Type
        case 'p'
                Kc = 5/K; 
        case 'pi'
                Kc = (2*damping*w0*T-1)/K;
                Ti = (2*damping*w0*T-1)/(w0*w0*T);
        case 'pid'
                Kc = (2*damping*w0*T-1)/K;
                Ti = (2*damping*w0*T-1)/(w0*w0*T);
                Td = Ti/4;
    end                
% we use CHR table with 20% overshoot to generate PID parameters
else
    switch Type
        case 'p'
            % with 20% overshoot, same for setpoint tracking and disturbance rejection
            Kc = 0.7/alpha;
        case 'pi'
            if strcmp(Target,'SETPOINT')
                Kc = 0.6/alpha;
                Ti = T;
            else
                Kc = 0.7/alpha;
                Ti = 2.3*L;
            end
        case 'pid'
            if strcmp(Target,'SETPOINT')
                Kc = 0.95/alpha;
                Ti = 1.4*T;
                Td = 0.47*L;
            else
                Kc = 1.2/alpha;
                Ti = 2*L;
                Td = 0.42*L;
            end
    end                
end
% change the controller sign if necessary
Kc = Kc*SignOfGain;

%% ----------------------------------------------------------------
% export as Kp Ki Kd format
[c, Kp, Ki, Kd, N] = utPIDfromKTTtoKKKN(Model,Kc,Ti,Td,Nin,Type);
